environment = "staging"

vpc_cidr = "10.20.0.0/16"
public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnet_cidrs = ["10.20.11.0/24", "10.20.12.0/24"]

app_bucket_name = "tu-bucket-staging-unico-12345"

db_password_ssm_parameter = "/app/staging/db_password"

# Canary example
active_color = "blue"
traffic_weight_blue  = 90
traffic_weight_green = 10
desired_capacity_blue  = 2
desired_capacity_green = 1

enable_vpc_peering = false
