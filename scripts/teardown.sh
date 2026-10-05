#!/usr/bin/env bash
# Delete every lab stack (reverse order) to stop all charges.
# Usage: ./scripts/teardown.sh <bucket-name> [region]
set -euo pipefail
BUCKET=${1:?"bucket name required"}
REGION=${2:-us-east-1}
aws s3 rm "s3://$BUCKET" --recursive --region "$REGION" || true
for s in website efs rds vpc; do
  echo "==> Deleting lab-$s"
  aws cloudformation delete-stack --region "$REGION" --stack-name "lab-$s"
  aws cloudformation wait stack-delete-complete --region "$REGION" --stack-name "lab-$s"
done
