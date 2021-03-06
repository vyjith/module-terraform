variable "region" {

    default = "ap-south-1"
  
}

variable "access_key" {

    description = "my access key"
    default = "Please access key"
  
}

variable "secret_key" {

    description = "my secret key"
    default = "Secret key"
  
}

variable "cidr" {

    default = "172.17.0.0/16"
  
}

variable "subnets" {

    default = "3"
  
}

variable "project" {

    default = "uber"
  
}
