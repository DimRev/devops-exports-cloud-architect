import boto3

s3 = boto3.client('s3')
# s3.create_bucket(Bucket='my-experts-dimrev')

# s3.upload_file('file.txt', 'my-experts-dimrev', 'test.txt')
response = s3.list_objects(Bucket='my-experts-dimrev')

print(f"NAME\t\t\tSIZE\t\tLAST MODIFIED")
for obj in response['Contents']:
    print(f"{obj['Key']}\t\t{obj['Size']}\t\t{obj['LastModified']}")
