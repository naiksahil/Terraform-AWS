terraform {
  backend "s3" {
    bucket         = "884348118743-terraform-states"
    key            = "remote_state/terraform.tfstate"
    region         = "us-east-2"
    use_lockfile   = true
    encrypt        = true
  }
}
