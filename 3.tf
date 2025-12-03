data "aws_vpc" "default" { # get the default VPC
  default = true
}

locals {
  key_name = "terraform-exercise"
}

resource "aws_security_group" "app-sg" {
  name        = "terraform-app-sg"
  description = "Allow SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress { # allow ingress to ssh port from internet
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # allow any egress traffic
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create private RSA key of size 4096 bits for ssh access
resource "tls_private_key" "terraform-exercise" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# create key pair based on tls private key above
resource "aws_key_pair" "terraform-exercise" {
  key_name   = local.key_name
  public_key = tls_private_key.terraform-exercise.public_key_openssh
}

# write pem identity file to local folder
resource "local_file" "terraform-exercise" {
  content  = tls_private_key.terraform-exercise.private_key_pem
  filename = "terraform-exercise.pem"
  file_permission = 0600 # trim down access so you can use the file right away to connect with ssh
}

resource "aws_instance" "app-server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.app-sg.id ]
  associate_public_ip_address = true
  key_name = local.key_name

  user_data = file("${path.module}/userdata.sh") # userdata file to write file and content
}

output "public_ip" {
  value = aws_instance.app-server.public_ip
}

# % ssh -i ./terraform-exercise.pem ubuntu@3.253.195.117
# Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.14.0-1017-aws x86_64)

#  * Documentation:  https://help.ubuntu.com
#  * Management:     https://landscape.canonical.com
#  * Support:        https://ubuntu.com/pro

# This system has been minimized by removing packages and content that are
# not required on a system that users do not log into.

# To restore this content, you can run the 'unminimize' command.
# Last login: Wed Dec  3 06:52:48 2025 from 194.35.121.165
# To run a command as administrator (user "root"), use "sudo <command>".
# See "man sudo_root" for details.

# ubuntu@ip-172-31-1-125:~$ cat hello-world.txt 
# foo