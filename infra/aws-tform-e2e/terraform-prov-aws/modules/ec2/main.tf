// Create aws_ami filter to pick up the ami available in your region
data "aws_ami" "ubuntu-2004" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "kubernetes-master-pub" {
  ami                         = data.aws_ami.ubuntu-2004.id
  associate_public_ip_address = true
  instance_type               = var.default_instance
  key_name                    = var.key_name
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]
  
  root_block_device {
    volume_size = 40
  }  

  tags = {
    Name = "${var.namespace}-EC2-MASTER-pub"
    Type = "k8s"
    Role = "master"
  }

  # Copies the ssh key file to home dir
  provisioner "file" {
    source      = "./${var.key_name}.pem"
    destination = "/home/ubuntu/${var.key_name}.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }
  }
  
  //chmod key 400 on EC2 instance
  provisioner "remote-exec" {
    inline = ["chmod 400 ~/${var.key_name}.pem"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }
  }
}

resource "aws_instance" "kubernetes-worker-pub" {
  ami                         = data.aws_ami.ubuntu-2004.id
  associate_public_ip_address = true
  instance_type               = var.default_instance
  key_name                    = var.key_name
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]
  count = 1

  tags = {
    Name = "${var.namespace}-EC2-WORKER-pub"
    Type = "k8s"
    Role = "worker"
  }

  root_block_device {
      volume_size = 40
  }  

  # Copies the ssh key file to home dir
  provisioner "file" {
    source      = "./${var.key_name}.pem"
    destination = "/home/ubuntu/${var.key_name}.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }
  }
  
  //chmod key 400 on EC2 instance
  provisioner "remote-exec" {
    inline = ["chmod 400 ~/${var.key_name}.pem"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }
  }
}

# resource "aws_instance" "kubernetes-worker-priv" {
#   ami                         = data.aws_ami.ubuntu-2004.id
#   associate_public_ip_address = false
#   instance_type               = var.default_instance
#   key_name                    = var.key_name
#   subnet_id                   = var.vpc.private_subnets[1]
#   vpc_security_group_ids      = [var.sg_priv_id]
#   count = 2
#   tags = {
#     Name = "${var.namespace}-EC2-WORKER-${count.index+1}-priv"
#     Type = "k8s"
#     Role = "worker"
#   }
# }