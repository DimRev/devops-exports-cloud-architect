# Cloud P2

- [back](../README.md)

## Cli AWS

To use AWS in the cli, we need to create Access Keys for our user, it's not the best practice to create an Access Key for the root user.

To configure the aws cli for our user we'll use the command

```bash
aws configure
```

The configure will start a wizard that prompt us for access key, secret key, region and output format

## S3

S3 is the AWS's storage bucket, to test / work with our cli, lets use the command

```bash
aws s3 mb s3://my-exports-bucket
```

- aws cli app
- s3 service
- mb - make bucket
- s3://my-cool-bucket - bucket name

![S3 Bucket](./assets/Pasted%20image%2020250224182057.png)

Now lets create a file and push it into our bucket

![S3 Bucket Upload](./assets/Pasted%20image%2020250224182316.png)

We can download the file from the bucket using those cmds as well

![S3 Bucket Download](./assets/Pasted%20image%2020250224182501.png)

to remove the bucket we can use the cmd `s3 rb`

![S3 Bucket Remove](./assets/Pasted%20image%2020250224182552.png)

The `rb` - remove bucket command fails because the bucket is not empty

So lets clean the bucket using the cmd

```bash
aws s3 rm <bucket> --recursive
```

![S3 Bucket RM --recursive](./assets/Pasted%20image%2020250224182801.png)

![S3 Bucket Remove Bucket](./assets/Pasted%20image%2020250224182815.png)

## EC2

If we want to create a new EC2 instance we'll have to use this cmd:

```bash
aws ec2 run-instances --image-id ami-0abcdef1234567890 --count 1 --instance-type t2.micro --key-name MyKeyPair --security-group-ids sg-0123456789abcdef0 --subnet-id subnet-6e7f829e
```

- Image ID:
  We can pick the image-id from the EC2 AMI catalog:
  ![[Pasted image 20250224183200.png]]
- KeyPair:
  We pick it from the keypairs we have
- Security-group-id:
  We pick it from the securty groups
- Subnet:
  VPC

## IAM

I am is the service that's incharge of users in our aws acc

to create a new user we can use

```bash
aws iam create-user --user-name checkuser
```

We can give users permissions with the policy arn for example:

```bash
aws iam attach-user-policy --user-name checkuser --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
```

From the example above it's important to say that using AWS cli you can do everything that can be done via the AWS server

Using AWS CLI we can write whole scripts that control our deployment and so on for example in python we can use the boto3 lib

```python
import boto3

s3 = boto3.client('s3')

s3.create_bucket(Bucket='my-experts-dimrev')
```

This will create a bucket in our aws

We can use boto to upload a file:

```python
import boto3

s3 = boto3.client('s3')

s3.upload_file('file.txt', 'my-experts-dimrev', 'test.txt')
```

# Summery

We spoke about aws CLI, the cli helps creating and managing resources, there are also SDK libraries like boto3 that can be used to write code to work with AWS

The next way for us to work with AWS is infrastructure as code, the infra-as-code works in a that we write the required end-state and the infra-as-code tools does everything to make it happen

## Terraform

Terraform is an infrastruction as code tool, via terraform we can define the end state and terraform will do everything untill the end-state is achived

```tf
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
}

output "instance_ip" {
  value = aws_instance.example.public_ip
}
```

- Provider - Which cloud we are talking with "aws"
- Resource - Which service are we talking with, "EC2"-"example"
- Output - What to print to the screen in the end,
  ![[Pasted image 20250224195216.png]]

As we initialized the terraform, a new dir was created in our project `.terraform` and `.terraform.lock.hcl`

```bash
terraform init

terraform plan

terraform apply
```

After we've created a plan and applyed it, a terraform state will be created in our dir

For example we've manually changed the instance type to t2.small, lets run plan

![Terraform Plan](./assets/Pasted%20image%2020250224200233.png)

We can see that terraform detected that the instance is mismatched and we can apply the changes,

Another advantage we have in terraform is that we can do `terraform destroy`
Which basically destroys all the infra that we created and that we keep the state of it in our terraform file

### Data source

The problem we have at the moment with our terraform file is that everything is hard coded, we can create another file called `data_source.tf` to hold our sources

## Local values

```tf
locals {
  common_tags = {
    Name = "Example"
    Environment = "Production"
    Owner       = "DevOps Team"
  }
}
```
