data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


module "web" {
  source = "git::https://github.com/mateoBG77/terraform-aws-pizza-del-esgi.git?ref=v0.2.0"

  project     = "pizza-del-esgi"
  environment = var.environment

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  ami_id                = data.aws_ami.debian.id
  instance_type         = var.instance_type
  instance_profile_name = "LabInstanceProfile"

  min_size = 2
  max_size = 4

  depends_on = [aws_ssm_parameter.db_password]
}
