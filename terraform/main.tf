provider "aws" {
  region = "ap-south-1"
}

resource "aws_security_group" "grafana_sg" {
  name        = "grafana_sg"
  description = "Allow SSH and Grafana"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "grafana_ec2" {
  ami           = "ami-03f4878755434977f"  # ✅ Valid AMI for ap-south-1
  instance_type = "t2.micro"
  key_name      = "grafana-key"

  vpc_security_group_ids = [aws_security_group.grafana_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apt-transport-https software-properties-common wget
              wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
              add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
              apt-get update -y
              apt-get install -y grafana
              systemctl enable grafana-server
              systemctl start grafana-server
              EOF

  tags = {
    Name = "GrafanaEC2"
  }
}

