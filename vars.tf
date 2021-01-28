variable "region" {
  description = "AWS region we deploying to"
  type        = string
}

variable "app_name" {
  description = "Name of the application to deploy"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 Instnaces to run in the ASG (e.g. t2.micro)"
  type        = string
}

variable "min_size" {
  description = "The minimum number of EC2 Instances to run in the ASG"
  type        = number
}

variable "max_size" {
  description = "The maximum number of EC2 Instances to run in the ASG"
  type        = number
}

variable "desired_size" {
  description = "The desired number of EC2 Instances to run in the ASG"
  type        = number
}

variable "elb_ports_in" {
  description = "The port number the ELB should listen on for HTTP requests"
  type        = list(object({
    port = number
    protocol = string
    ssl = bool
    prefix = string
  }))
}

variable "elb_ports_out" {
  description = "The port number the ELB should listen on for HTTP requests"
  type        = list(object({
    port = number
    protocol = string
    ssl = bool
    prefix = string
  }))

  default = [
    {
      port = 0
      protocol = "-1"
      ssl = false
      prefix = "0.0.0.0/0"
    }
  ]
}

variable "backend_ports_in" {
  description = "The port number the ELB should listen on for HTTP requests"
  type        = list(object({
    port = number
    protocol = string
    ssl = bool
    prefix = string
  }))

  default = [
    {
      port = 80
      protocol = "tcp"
      ssl = false
      prefix = "0.0.0.0/0"
    }
  ]
}

variable "backend_ports_out" {
  description = "The port number the ELB should listen on for HTTP requests"
  type        = list(object({
    port = number
    protocol = string
    ssl = bool
    prefix = string
  }))
  default = [
    {
      port = 0
      protocol = "-1"
      ssl = false
      prefix = "0.0.0.0/0"
    }
  ]
}

variable "enable_ssh_port" {
  description = "Set SSH port"
  type       = number

  default    = 22
}

variable "enable_ssh" {
  description = "Toggle whether to allow SSH access to the created host"
  type        = bool

  default     = false
}

variable "enable_ssh_prefix" {
  description = "Allow SSH from the specified prefix"
  type        = string

  default     = "0.0.0.0/32"
}

variable "tag_list" {
  description = "List of tags to apply"
  type = map(string)
}

