#!/bin/bash

# Read user variables from user input
read -p "Enter AWS Account ID: " AWS_ACCOUNT_ID
read -p "Enter AWS Region: " AWS_REGION
read -p "Enter AWS Repository Name: " AWS_REPOSITORY
read -p "Enter AWS Image Tag: " AWS_IMAGE_TAG

docker tag l3-web-service:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AWS_REPOSITORY:$AWS_IMAGE_TAG

docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AWS_REPOSITORY:$AWS_IMAGE_TAG