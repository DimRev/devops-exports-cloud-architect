# Terraform P2

- [back](../README.md)

Today we're continuing talking about Terraform, we'll talk about EKS (AWS Kubernetes Service), And datastreaming service

To recap the last lesson we spoke about methods to connect to AWS which are `aws-cli`, code lib `boto3`, and infra as code like `terraform`

We spoke about Terraform's ability to define `data sources` and use those data sources in code, Another ability is defining `local values` and `variables` we also saw that terraform has its own methods like `length`, loops and so on

So what is the difference between local values and variables, local values only apply in the same file they are defined while variables can work in the whole env and can be written over

## Terraform Variables

Uptill now we didn't give terraform file name any special meaning or functionality, that changes with `variables.tf`

_example:_

```tf
# variables.tf

variable "region" {
  type        = string
  description = "The AWS region where the resources will be created"
  default     = "us-west-2"
}

variable "instance_type" {
  type        = string
  description = "Type of EC2 instance to create"
  default     = "t2.micro"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to use"
}

variable "instance_count" {
  type        = number
  description = "Number of instances to launch"
  default     = 2
}

variable "instance_tags" {
  type        = map(string)
  description = "Tags to apply to each instance"
}
```

Let's extend our example with this main.tf:

```tf
# main.tf

provider "aws" {
  region = var.region
}

resource "aws_instance" "example" {
  count         = var.instance_count
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type

  availability_zone = element(var.availability_zones, count.index)

  tags = var.instance_tags
}

output "instance_public_ips" {
  value = aws_instance.example[*].public_ip
}
```

The interesting part in this main.tf file is the `region` we can see that it imports a var.region from our variables.tf file

```tf
# terraform.tfvars

region = "us-east-1"

instance_type = "t3.medium"

availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

instance_count = 3

instance_tags = {
  Environment = "production"
  Owner       = "admin-team"
}
```

The tfvars file is going to overrite our variables with the new values defined in it, the important part is that a variable should already exist with the name that we're planning to overrite.

To use a `tfvars` file to overrite a variables we'll use the flag `--var-files="/path/to/file.tfvars"`

```bash
terraform apply --var-file="path/to/file.tfvars"
```

## Terraform Modules

Another thing we need to remember that `terraform apply` will apply **ALL** the `.tf` files that are in the file, this is where terraform modules come into play

- They keep our files tree clean
- They help us to apply only parts of our infra
- We can use external modules (like libs for programing)

```bash
 # File structure
 terraform/
	 |-modules/
	 |	 |_main.tf
	 |	 |_variables.tf
	 |	 |_outputs.tf
	 |_main.tf
```

```tf
# modules/ec2_instance/main.tf

resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = var.tags
}
```

```tf
# modules/ec2_instance/outputs.tf

output "instance_id" {
  description = "The ID of the created EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "The public IP address of the instance"
  value       = aws_instance.this.public_ip
}
```

```tf
# modules/ec2_instance/variables.tf

variable "ami" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Type of EC2 instance to create"
  type        = string
  default     = "t2.micro"
}

variable "tags" {
  description = "Tags to apply to the instance"
  type        = map(string)
}
```

If we look at our project our `ec2_instance` module looks like a regular terraform repo that we've encountered already, but if we look out of it into the root's main.tf we can see that it calls to the module using this

```tf
# main.tf

provider "aws" {
  region = "us-east-1"
}

module "ec2_instance" {
  source = "./modules/ec2_instance"
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.micro"

  tags = {
    Name        = "my-instance"
    Environment = "dev"
  }
}

output "instance_id" {
  value = module.ec2_instance.instance_id
}

output "public_ip" {
  value = module.ec2_instance.public_ip
}
```

We can see the main calls the module, and binds the module's outputs.

Another thing we spoke about is that we can use ready to use modules

## Terraform state

What about terraform's state, the convention is to store the state in dynamo db as it allows us to share the state between a couple of people while locking reading and wrinting

Creating a bucket

```bash
aws s3api create-bucket --bucket <bucket-name> --region us-east-1
```

Create a dynamo table

```bash
aws dynamodb create-table --table-name terraform-locking-user100 --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
```

Now lets create a backend configuration that will hold our terraform state we define it in our dir's `backend.tf` file

```tf
terraform {
  backend "s3" {
    bucket         = "dimar-terraform-state-bucket-user1"
    key            = "prod/terraform.tfstate"           # Path inside the bucket
    region         = "us-east-1"
    encrypt        = true                               # Encrypt the state file
    dynamodb_table = "terraform-locking-user100"        # For state locking
  }
}
```

To breakdown the backend's functionality

- A State file is inside the bucket
- A user overrites the state, and a lock file is being created
  - If another user tries to overrite he queries the lockfile and it ofc exists so he fails
- The state change finishes, the lockfile is being deleted, now other users can change the state again

**_NOTE:_** `backend.tf` is a file that will define terraform's behavior

Let's kill our DynamoDB table and our S3 bucket
To clear the bucket lets first clean in

```bash
# RM --recursive
aws s3 rm s3://<bucket-name> --recursive

# Remove bucket
aws s3 rb s3://<bucket-name>
```

```
aws dynamodb delete-table --table-name <table-name>
```

## EKS - Elastic Kubernetes Service

Up till now when we worked with k8s we worked with minikube, which is basically a local demo of a Kubernetes Cluster

Now we're going to config and init a AWS-EKS cluster, but to do that we'll need to config multiple different components and parts, and when we start and stop the cluster manually we could leave artifacts that would cost us alot of money.

So the best way to handle that is to use Terraform because terraform will destroy all the services that it created.

Lets start defining and deploying our EKS:

**main.tf**

```tf
provider "aws" {
  region = var.region
}

# ✅ Updated VPC Module (Latest Version)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"  # Upgrade to latest version
  name    = "eks-vpc"
  cidr    = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name = "eks-vpc"
  }
}

# ✅ Updated EKS Module
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.16.0"  # Latest stable version
  cluster_name    = var.cluster_name
  cluster_version = "1.27"

  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  eks_managed_node_groups = {
    eks_nodes = {
      desired_capacity = var.desired_capacity
      max_size         = var.max_size
      min_size         = var.min_size

      instance_types = ["t3.medium"]

      labels = {
        Environment = "dev"
      }
    }
  }

  cluster_endpoint_public_access = true

  tags = {
    Name = "eks-cluster"
  }
}
```

**outputs.tf**

```tf
output "cluster_endpoint" {
  description = "The EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_security_group_id" {
  description = "The security group of the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
```

**variables.tf**

```tf
# variables.tf
variable "region" {
  description = "AWS region where the cluster will be deployed"
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  default     = "my-eks-cluster"
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  default     = 3
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type for the worker nodes"
  default     = "t3.medium"
}
```

**terraform.tfvars**

```tf
region         = "us-east-1"
instance_count = 2
instance_type  = "t3.medium"
ami_id         = "ami-04b4f1a9cf54c11d0"
```

Lets talk briefly about **VPC** using a city analogy:

- VPC is a city
- Subnet is a street, some streets are private streets and some are public
- Security groups are our gates into houses, in the streets, in the small city

Why would we create a separate VPC for our EKS? The answer is simple the EKS is using alot of default services and so we want to have a _CLEAN_ env for our K8s, and we want to fully control and fully define the entrypoint and exit point from our EKS cluster

EKS is an area where Terraform stops being another useful tool but a requirment

After we apply our eks terraform we'll init our cluster:

![Apply EKS](./assets/Pasted%20image%2020250303202238.png)

Now that we've created a eks cluster, lets setup our kubectl so that it would point to our remote cluster instead of minikube

```bash
aws eks --region us-east-1 update-kubeconfig --name my-eks-cluster
```

Running this cmd will change our kubectl config so it'll work with our eks

## Data Streaming - Kinesis

Lets create a datastream:

We'll call it my-data-stream
We'll create a server listening to /send post requests this server sends the post requests to our AWS kinesis service

```python
from flask import Flask, jsonify, request
import boto3
import json
import os

# Flask app initialization
app = Flask(_name_)

# Initialize the Kinesis client
kinesis_client = boto3.client('kinesis', region_name='us-east-1')

# Kinesis stream name (you need to replace with your stream name)
KINESIS_STREAM_NAME = 'my-data-stream'


@app.route('/')
def index():
    return "Welcome to the Data Streaming Demo!"


# Producer: Send data to the Kinesis stream
@app.route('/send', methods=['POST'])
def send_data():
    data = request.json
    partition_key = data.get("partition_key", "default_key")

    # Send data to Kinesis
    response = kinesis_client.put_record(
        StreamName=KINESIS_STREAM_NAME,
        Data=json.dumps(data),
        PartitionKey=partition_key
    )

    return jsonify({"status": "Data sent to Kinesis", "response": response})


if _name_ == '_main_':
    # Get AWS credentials from environment variables or the AWS credentials file
    app.run(debug=True)

```

and another app that baiscally listens and prints the socket msgs:

```python
import boto3

kinesis_client = boto3.client('kinesis', region_name='us-east-1')
stream_name = 'my-data-stream'

shard_iterator = kinesis_client.get_shard_iterator(
    StreamName=stream_name,
    ShardId='shardId-000000000000',  # Adjust to your specific shard ID
    ShardIteratorType='TRIM_HORIZON'
)['ShardIterator']

while True:
    response = kinesis_client.get_records(ShardIterator=shard_iterator, Limit=10)

    # Process each record
    for record in response['Records']:
        data = record['Data']
        print(f"Received record: {data}")

    # Get the next shard iterator
    shard_iterator = response['NextShardIterator']
```

Here's the result for sending posts:
![Post result](./assets/Pasted%20image%2020250303200851.png)
We can see that our data-streams are being sent to the monitor that's listening to the kinesis service live:

## Functions and conditions:

```tf
locals {
  second_fruit = "banana"
}

output "second_fruit" {
  value = local.second_fruit
}
```

This terraform code doesn't control AWS services or anything, it simply prints, and yes we can terraform apply this code
