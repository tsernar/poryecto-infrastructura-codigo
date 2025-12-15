environment = "prod"

vpc_cidr = "10.30.0.0/16"
public_subnet_cidrs  = ["10.30.1.0/24", "10.30.2.0/24"]
private_subnet_cidrs = ["10.30.11.0/24", "10.30.12.0/24"]

app_bucket_name = "tu-bucket-prod-unico-12345"

db_password_ssm_parameter = "/app/prod/db_password"

active_color = "blue"
traffic_weight_blue  = 100
traffic_weight_green = 0
desired_capacity_blue  = 2
desired_capacity_green = 0
