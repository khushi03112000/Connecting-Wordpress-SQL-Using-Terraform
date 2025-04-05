# Creating Infrastructure with Terraform

## Project Description

This project demonstrates how to provision a complete AWS infrastructure using Terraform for deploying a WordPress website connected to a MySQL database.

The setup follows a real-world architecture:

- WordPress is deployed inside a Docker container on an EC2 instance in a Public Subnet.
- MySQL is deployed inside a Docker container on an EC2 instance in a Private Subnet (using a custom AMI with pre-installed Docker & MySQL).
- Both instances reside inside a custom VPC with proper security group configurations.
- Bastion Host (WordPress EC2) is used to SSH into the MySQL EC2 instance (since it has no internet access).

This project aims to showcase Infrastructure as Code (IaC) using Terraform in a secure and production-ready environment.

### Task: Infrastructure as Code using Terraform
 Objective:
Write an Infrastructure as Code (IaC) using Terraform to automate the creation of a complete environment in AWS.
Requirements:
1. Create a VPC
    - Use Terraform to create a Virtual Private Cloud (VPC).
2. Create 2 Subnets inside the VPC:
    - Public Subnet - This subnet should be accessible from the public internet.
    -  Private Subnet - This subnet should be restricted from public access (no direct internet access)
3. Create an Internet Gateway
   - Create a public-facing Internet Gateway (IGW) to allow internet access.
   - Attach this IGW to the VPC.
4. Create a Route Table
    - Create a route table for the Internet Gateway.
    - Configure it to allow traffic from the public subnet to the internet.
    - Associate this route table with the Public Subnet.
5. Launch EC2 Instance with WordPress
    - Deploy an EC2 instance in the Public Subnet.
    - Pre-configure the instance with WordPress setup.
    - Create a Security Group allowing inbound traffic on port `80` (HTTP) so that clients can access the WordPress site.
6. Launch EC2 Instance with MySQL
    - Deploy an EC2 instance in the Private Subnet.
    - Pre-configure the instance with MySQL setup.
    - Create a Security Group allowing inbound traffic on port `3306` (MySQL) only from the WordPress instance.
    - This instance should not be accessible from the public internet.
 Note:
    - The WordPress EC2 instance is deployed in the Public Subnet so that clients from the internet can access the WordPress site.
    - The MySQL EC2 instance is deployed in the Private Subnet to ensure security — only the WordPress instance should be able to connect to the MySQL database (no public access).

## Solution
Terraform Code : 

Provider :
Provider needs to be mention which is aws along with region and profile.
![image](https://github.com/user-attachments/assets/744d3360-256b-4994-b5a9-7ba0dcc801db)

VPC :
VPC is created with IP range to provide to subnet.

![image](https://github.com/user-attachments/assets/0a72ba14-9adf-43a2-9df0-5e38d4d374f7)

![image](https://github.com/user-attachments/assets/bb3c8e2d-4841-4885-a088-3be326f663b0)

Public Subnet:
Create a public subnet in the above created VPC, in the availability zone us-east-1a to launch the Wordpress. Also enable the auto public ip assign so that client can access the site. Assign IP address range.

![image](https://github.com/user-attachments/assets/c1a1c69d-0915-4543-a7c1-16321b058277)


Private Subnet:
Creating a private subnet in the same VPC to launch the MYSQL in it so that is is secure and cannot be access by the outside. IP range is provided. It is launched in ap-south-1b zone.

![image](https://github.com/user-attachments/assets/589a2ff6-f726-4cc8-97fe-0745dae83a7a)

Internet Gateway:
Creating an internet gateway so that our public subnet can connect to outside world and client can access the instance.

![image](https://github.com/user-attachments/assets/866a4fcb-2562-4f5d-83e3-340ae7a13d7e)


Route Tables:
A route table contains a set of rules, called routes, that are used to determine where network traffic from your subnet or gateway is directed. Also we have to associate the route table to our public subnet so that it can know where is the internet gateway to connect to the outside world.

![image](https://github.com/user-attachments/assets/9c1ce098-5ace-4014-9deb-dde4144bf472)
![image](https://github.com/user-attachments/assets/286adc53-00ac-4d51-a660-967baf168090)


Mysql AMI using snapshot:
Creating our own AMI using snapshot having Docker install with mysql image already in it.

![image](https://github.com/user-attachments/assets/8d6d2b8e-17ef-461b-9f4a-1d6357c70e56)


Mysql Instance:
Launching an instance in the private subnet for the MYSQL using docker. For this first we have to create a security group which allows port number 3306 because MYSQL runs on port number 3306. Next I launch an instance in the private subnet using my own AMI and above created security group. At last I launch MYSQL container inside the instance.
Security Group:

![image](https://github.com/user-attachments/assets/873ea091-bdfb-4d85-8b64-e9809b22353b)

![image](https://github.com/user-attachments/assets/f205a322-b7bb-4a79-a92e-fc514ba0fc6f)

![image](https://github.com/user-attachments/assets/a8d6bad7-ee69-4735-a662-684ab1420763)

Wordpress Instance:
Launching another instance in the public subnet for the WordPress. But again for this we have first create a security group which allows port 80 since WordPress runs on port 80. Then I launch EC2 instance using my AMI inside which I launch docker container for the WordPress.

Security Group:

![image](https://github.com/user-attachments/assets/4ec16b63-b7e1-4f08-8225-f73af456793e)
![image](https://github.com/user-attachments/assets/1906bbff-8ff4-43f5-834e-880a65cfae23)

![image](https://github.com/user-attachments/assets/3d452844-4154-4a56-bff3-1de46b637fdd)


So now you can access the WordPress using the public IP of the of the Wordpress instance, which stores all its data in the MYSQL which is running in the private subnet so that your data is secure.

![image](https://github.com/user-attachments/assets/22f74d7d-075f-4fda-b7c0-d6b4b16cab27)

![image](https://github.com/user-attachments/assets/ad1fedef-7c6c-4e68-9660-998b4a32dd24)

![image](https://github.com/user-attachments/assets/3cd106c8-cd81-4830-8d0f-34cc3b08e1c3)



---




