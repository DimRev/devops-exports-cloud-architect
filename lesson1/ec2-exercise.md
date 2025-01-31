# Basic EC2 Free Tier Exercise

- [Back](../README.md)
- [K8s Exercise](k8s-exercise.md)

## Launching and Managing an EC2 Instance

- [Solution](ec2-exercise.sh)

**Explanation**: Amazon EC2 allows you to create virtual machines (instances) in the cloud. With the Free Tier, you can launch a t2.micro instance at no cost for eligible accounts.
**Task**: 1. Log in to the AWS Management Console. 2. Navigate to the EC2 service. 3. Launch an EC2 instance using the following steps:

- Select the Free Tier eligible Amazon Linux 2 AMI.
- Choose t2.micro as the instance type.
- Configure the instance with default settings.
- Add a key pair for SSH access.
- Allow HTTP (port 80) and SSH (port 22) traffic in the security group.

## Connect to the instance using an SSH client or AWS Systems Manager Session Manager.

## Install and start an Nginx web server:

- Update the system packages: `sudo yum update -y`
- Install Nginx: `sudo amazon-linux-extras enable nginx1`
- Start the Nginx service: `sudo service nginx start`

## Test the server by accessing the instance's public IP address in a browser.

**Example**:

# Example SSH Connection

ssh -i my-key.pem ec2-user@<instance-public-ip>
