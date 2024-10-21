variable "instance_ami" {
  default = "ami-04a81a99f5ec58529" 
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
 default = "EPA-test2"
}

variable app_private_ip {
  default = "10.0.1.10"
}

variable "public_subnet_id" {

}


variable "ec2_security_group_id" {

}

variable "private_subnet_id" {
}

variable "naming_prefix" {

}