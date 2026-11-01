variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Assignment on Deploying a MERN Application through Terraform and Ansible"
  type        = string
  default     = "travelmemory"
}

variable "vpc_id" {
  description = "Existing AWS VPC ID"
  type        = string
  default     = "vpc-01c802cbcc72851e8"
}

variable "public_subnet_id" {
  description = "Existing public subnet ID"
  type        = string
  default     = "subnet-0a9e582f8a988b34a"
}

variable "private_subnet_id" {
  description = "Existing private subnet ID"
  type        = string
  default     = "subnet-036fa41084dc466f4"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidr" {
  description = "Your public IP address with /32"
  type        = string
  sensitive   = true
}

variable "key_pair_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
  default     = "shiwanshu-HV-keypair"
}

variable "public_route_table_id" {
  description = "Existing public route table ID"
  type        = string
  default     = "rtb-0868a397c70af409e"
}

variable "private_route_table_id" {
  description = "Existing private route table ID"
  type        = string
  default     = "rtb-059768deaa5e1c5eb"
}