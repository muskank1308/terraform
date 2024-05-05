variable "region" {
  default = "us-east-1"
}

variable "os_name" {
  default = "ami-07caf09b362be10b8"
}

variable "key" {
    default = "linux-kp"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "vpc_cidr" {
  default = "10.10.0.0/16"
}

variable "subnet_cidr" {
  default = "10.10.1.0/24"
}
