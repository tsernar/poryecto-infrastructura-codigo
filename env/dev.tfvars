environment = "dev"

vpc_cidr = "10.10.0.0/16"
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]

app_bucket_name = "tu-bucket-dev-unico-12345"

db_password_ssm_parameter = "/app/dev/db_password"

# Blue/Green (dev: solo blue prendido)
active_color = "blue"
traffic_weight_blue  = 100
traffic_weight_green = 0
desired_capacity_blue  = 2
desired_capacity_green = 0

# Peering (apagado por defecto)
enable_vpc_peering = false
