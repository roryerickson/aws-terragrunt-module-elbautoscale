# ---------------------------------------------------------------------------------------------------------------------
# USE THE DEFAULT VPC AND SUBNETS
# To keep this example simple, we use the default VPC and subnets, but in real-world code, you'll want to use a
# custom VPC.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_vpc" "this" {

  tags = {
    tg = "true"
  }

}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.this.id

  tags = {
    private = "true"
  }

}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.this.id

  tags = {
    private = "false"
  }

}

data "aws_ami" "this" {

  most_recent = true
  owners      = ["self"]

  tags = {
    project = var.app_name
  }



}