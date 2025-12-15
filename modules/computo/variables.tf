variable "environment" { 
    type = string 
}
variable "app_name" { 
    type = string 
}

variable "vpc_id" { 
    type = string 
}
variable "public_subnet_ids" { 
    type = list(string) 
}
variable "private_subnet_ids" { 
    type = list(string) 
}

variable "instance_type" { 
    type = string 
}
variable "min_size" { 
    type = number 
}
variable "max_size" { 
    type = number 
}

variable "desired_capacity_blue" { 
    type = number
}
variable "desired_capacity_green" { 
    type = number 
}

variable "active_color" { 
    type = string 
}
variable "traffic_weight_blue" { 
    type = number 
}
variable "traffic_weight_green" { 
    type = number
}
