#!/usr/bin/env bash
# Upload a static site folder (index.html, css/, images/) to the website bucket.
# Usage: ./scripts/upload-website.sh <bucket-name> <site-folder>
set -euo pipefail
BUCKET=${1:?"bucket name required"}
SITE=${2:?"site folder required"}
aws s3 sync "$SITE" "s3://$BUCKET" --delete --cache-control "max-age=300"
echo "Website: http://$BUCKET.s3-website-$(aws configure get region || echo us-east-1).amazonaws.com"
