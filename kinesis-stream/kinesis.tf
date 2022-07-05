terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}

module "kinesis-stream" {

  source  = "rodrigodelmonte/kinesis-stream/aws"
  version = "v2.0.3"

  name                      = "test-kinesis-openssl-1p0"
  shard_count               = 1
  retention_period          = 24
  shard_level_metrics       = ["IncomingBytes", "OutgoingBytes"]
  enforce_consumer_deletion = false
  # encryption_type           = "KMS"
  # kms_key_id                = "alias/aws/kinesis"
  tags                      = {
      Name = "aws-kinesis-openssl-1p0"
  }
}
