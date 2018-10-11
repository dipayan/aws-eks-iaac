init:
	@read -r -p "Enter the S3 Bucket Name for storing your state : " state_bucket; \
	read -r -p "Enter the S3 Bucket Key for storing your state : " state_bucket_key; \
	read -r -p "Enter the AWS Region : " state_bucket; \
	terraform init -backend-config "bucket=$$state_bucket" -backend-config "key=$$state_bucket_key" -backend-config "region=$$aws_region"

plan:
	terraform plan

apply:
	terraform apply