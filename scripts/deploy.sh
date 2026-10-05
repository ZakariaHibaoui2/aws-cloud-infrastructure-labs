#!/usr/bin/env bash
# Deploy the lab stacks in dependency order.
# Usage: ./scripts/deploy.sh <unique-bucket-name> [region]
set -euo pipefail

BUCKET=${1:?"usage: deploy.sh <unique-bucket-name> [region]"}
REGION=${2:-us-east-1}
ENV=lab
CFN="$(cd "$(dirname "$0")/../cloudformation" && pwd)"

deploy() {
  local stack=$1 template=$2; shift 2
  echo "==> Deploying $stack"
  aws cloudformation deploy \
    --region "$REGION" \
    --stack-name "$stack" \
    --template-file "$CFN/$template" \
    --no-fail-on-empty-changeset \
    "$@"
}

deploy "$ENV-vpc" 01-vpc.yaml --parameter-overrides EnvironmentName=$ENV
deploy "$ENV-rds" 02-rds-mysql.yaml --parameter-overrides EnvironmentName=$ENV
deploy "$ENV-efs" 03-efs.yaml --parameter-overrides EnvironmentName=$ENV
deploy "$ENV-website" 04-s3-static-website.yaml --parameter-overrides BucketName="$BUCKET"

echo "==> Stack outputs"
for s in vpc rds efs website; do
  aws cloudformation describe-stacks --region "$REGION" --stack-name "$ENV-$s" \
    --query "Stacks[0].Outputs[].[OutputKey,OutputValue]" --output table
done
