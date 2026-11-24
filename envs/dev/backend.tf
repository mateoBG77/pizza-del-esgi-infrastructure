terraform {
  backend "s3" {
    bucket       = "pizza-del-esgi-tfstate-mca"
    key          = "pizza-del-esgi/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
