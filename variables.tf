variable "aws_region" { 
    type = string 
    default = "us-east-1" 
}
variable "environment" { 
    type = string 
}

#partes de Networking

variable "vpc_cidr" { 
    type = string 
}

variable "public_subnet_cidrs" { 
    type = list(string) 
}

variable "private_subnet_cidrs" { 
    type = list(string) 
}

#computo

variable "app_name" { 
    type = string 
    default = "app" 
}
variable "instance_type" { 
    type = string 
    default = "t3.micro" 
}
variable "min_size" { 
    type = number 
    default = 2 
}
variable "max_size" { 
    type = number 
    default = 5
}
variable "desired_capacity_blue"  { 
    type = number 
    default = 2 
}
variable "desired_capacity_green" { 
    type = number 
    default = 0 
}

# Blue/Green traffic control
# active_color: "blue" o "green"

variable "active_color" {
  type        = string
  default     = "blue"
  validation {
    condition     = contains(["blue", "green"], var.active_color)
    error_message = "active_color debe ser 'blue' o 'green'."
  }
}

# Envio por porcentaje porcentajes (en vez de switch total)
variable "traffic_weight_blue"  { 
    type = number 
    default = 100 
}
variable "traffic_weight_green" { 
    type = number 
    default = 0 
}

#almacenamiento

variable "app_bucket_name" { 
    type = string 
}

#DB 

variable "db_engine" { 
    type = string 
    default = "postgres" 
}
variable "db_engine_version" { 
    type = string 
    default = "15.4" 
}
variable "db_instance_class" { 
    type = string 
    default = "db.t3.micro" 
}
variable "db_allocated_storage" { 
    type = number 
    default = 20 
}
variable "db_name" { 
    type = string 
    default = "appdb" 
}
variable "db_username" { 
    type = string 
    default = "appuser" 
}
variable "db_password_ssm_parameter" { 
    type = string 
} 

#vpc

variable "enable_vpc_peering" { 
    type = bool 
    default = false 
}
variable "peer_vpc_id" { 
    type = string 
    default = "" 
}
variable "peer_vpc_cidr" { 
    type = string 
    default = "" 
}
variable "peer_region" { 
    type = string 
    default = "us-east-1" 
}
variable "auto_accept_peering" { 
    type = bool 
    default = true 
}