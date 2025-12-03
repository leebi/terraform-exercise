data "aws_ami" "ubuntu" {
  owners      = ["099720109477"] # Canonical account
  most_recent = true # grab the newest one

  filter { # for current ubuntu LTS amd64 version
    name   = "name"
    values = ["ubuntu-minimal/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-minimal-*"]
  }

  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

output "ubuntu" {
  description = "ubuntu version"
  value = data.aws_ami.ubuntu.description
}