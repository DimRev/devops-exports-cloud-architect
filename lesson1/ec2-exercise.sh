#!/bin/bash
PATH_TO_KEY='./lesson1/my-key.pem'
PUBLIC_AWS_IP='127.0.0.1'

# Prerequisites - Start an EC2 instance

set -e

# Cleanup function to handle interruption or errors
cleanup() {
  echo "[INFO] Disconnecting from the instance..."
  exit
}

# Trap INT (Ctrl+C) and ERR to call the cleanup function
trap cleanup INT ERR

# SSH into the instance and execute commands
ssh -i "$PATH_TO_KEY" ec2-user@"$PUBLIC_AWS_IP" << 'EOF'

# Assignment 1 - Install and start an Nginx web server
echo "[ASSIGNMENT 1] Updating system packages..."
sudo yum update -y

echo "[ASSIGNMENT 1] Enabling and installing Nginx..."
sudo amazon-linux-extras enable nginx1
sudo yum install -y nginx

echo "[ASSIGNMENT 1] Starting the Nginx daemon..."
sudo service nginx start

# Assignment 2 - Test the server by accessing the instance's public IP address in a browser
echo "[ASSIGNMENT 2] Testing the server by accessing the public IP address..."
curl http://localhost

EOF

echo "[INFO] Press any key to curl the instance's public IP address..."
read -r -n 1
curl http://"$PUBLIC_AWS_IP"

# End of script
echo "[INFO] Script execution completed. Exiting."
