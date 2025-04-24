resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "public-subnet" {
  vpc_id= aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_security_group" "sg-pub" {
  vpc_id = aws_vpc.vpc.id
  ingress{
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress{
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress{
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"] 
  }
}


resource "aws_instance" "wordpress" {
  ami = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public-subnet.id
  security_groups = [aws_security_group.sg-pub.id]
  associate_public_ip_address = true
  key_name = "first-project"

  connection {
    type = "ssh"
    user = "ubuntu"
    host = self.public_ip
    private_key = file("/workspaces/Connecting-Wordpress-SQL-Using-Terraform/first-project.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install docker.io -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d --name wordpress-container -p 80:80 wordpress:latest"
    ]
  }
}

resource "aws_security_group" "sg-priv" {
  vpc_id = aws_vpc.vpc.id
  ingress{
    to_port = 22
    from_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress{
    to_port = 3306
    from_port = 3306
    protocol ="tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress{
    to_port = 0
    from_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "MySQL" {
  ami = "ami-08fb016af4af884bf"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private-subnet.id
  security_groups = [aws_security_group.sg-priv.id]
  key_name = "first-project"
  associate_public_ip_address = false

connection {
  type = "ssh"
  user = "ubuntu"
  host = aws_instance.MySQL.private_ip
  private_key =  file("/workspaces/Connecting-Wordpress-SQL-Using-Terraform/first-project.pem")
  bastion_host = aws_instance.wordpress.public_ip
  bastion_user = "ubuntu"
  bastion_private_key = file("/workspaces/Connecting-Wordpress-SQL-Using-Terraform/first-project.pem")
}

provisioner "remote-exec"{
  inline = [
    "sudo systemctl start docker",
    "sudo docker run -d --name mysql-container1 -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=wordpress -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=password -p 3306:3306 mysql:latest"
  ]
}
}
