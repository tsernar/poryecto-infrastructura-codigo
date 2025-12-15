data "aws_ssm_parameter" "db_password" {
  name = var.db_password_ssm_parameter
}

module "vpc" {
  source = "./modulos/vpc"

  name                 = "${var.app_name}-${var.environment}"
  cidr_block           = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "storage" {
  source = "./modulos/almacenamiento"

  bucket_name = var.app_bucket_name
  environment = var.environment
}

module "db" {
  source = "./modulos/db"

  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  db_instance_class    = var.db_instance_class
  db_engine            = var.db_engine
  db_engine_version    = var.db_engine_version
  db_allocated_storage = var.db_allocated_storage

  db_name     = var.db_name
  db_username = var.db_username
  db_password = data.aws_ssm_parameter.db_password.value
}

module "compute" {
  source = "./modulos/computo"

  environment = var.environment
  app_name    = var.app_name

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  instance_type = var.instance_type
  min_size      = var.min_size
  max_size      = var.max_size

  desired_capacity_blue  = var.desired_capacity_blue
  desired_capacity_green = var.desired_capacity_green

  active_color         = var.active_color
  traffic_weight_blue  = var.traffic_weight_blue
  traffic_weight_green = var.traffic_weight_green
}

#VPC Peering 
module "peering" {
  count  = var.environment == "prod" ? 1 : 0
  source = "./modulos/vpc-peering"

  requester_vpc_id          = module.vpc.vpc_id
  requester_vpc_cidr        = var.vpc_cidr
  requester_route_table_ids = module.vpc.route_table_ids

  accepter_vpc_id   = module.peer_vpc[0].vpc_id
  accepter_vpc_cidr = "10.40.0.0/16"

  auto_accept = true
}


####################
module "peer_vpc" {
  count  = var.environment == "prod" ? 1 : 0
  source = "./modulos/vpc"

  name                 = "peer-${var.environment}"
  cidr_block           = "10.40.0.0/16"
  public_subnet_cidrs  = ["10.40.1.0/24", "10.40.2.0/24"]
  private_subnet_cidrs = ["10.40.11.0/24", "10.40.12.0/24"]
}
