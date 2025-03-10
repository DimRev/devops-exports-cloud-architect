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