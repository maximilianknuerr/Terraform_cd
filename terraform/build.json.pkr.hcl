variable "ami_name_base" {
  type    = string
  default = "my_base_image"
}

variable "aws_profile" {
  type    = string
  default = "maximilian"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

data "amazon-ami" "ubuntu" {
    filters = {
        virtualization-type = "hvm"
        name = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
        root-device-type = "ebs"
    }
    owners = ["099720109477"]
    most_recent = true
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "ubuntu-ami" {
  ami_description = "my base image"
  ami_name        = "${var.ami_name_base}-${local.timestamp}"
  encrypt_boot    = false
  instance_type   = "t2.micro"
  profile         = var.aws_profile
  region          = var.aws_region
  source_ami      = data.amazon-ami.ubuntu.id
  ssh_username    = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.ubuntu-ami"]

  provisioner "file" {
    source = "upload"
    destination = "/tmp/packer"
  }

  provisioner "shell" {
    inline = ["sleep 20", "upload/configure-sinatra-app.sh"]
  }
}