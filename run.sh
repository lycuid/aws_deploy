#!/bin/sh
set -e

export AWS_ACCESS_KEY_ID="$INPUT_AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$INPUT_AWS_SECRET_ACCESS_KEY"

TARGET="$INPUT_TARGET"
S3_BUCKET_PATH="$INPUT_S3_BUCKET_PATH"
EC2_SSH_KEY="$INPUT_EC2_SSH_KEY"
EC2_REMOTE_ADDR="$INPUT_EC2_REMOTE_ADDR"
EC2_REMOTE_PATH="$INPUT_EC2_REMOTE_PATH"

# Installing aws cli for deploying to s3.
pip3 install awscli

## Setting up ssh.
eval "$(ssh-agent)"
echo "$EC2_SSH_KEY" | ssh-add -

## Deployment.
echo "Deploying assets to S3."
aws s3 sync $TARGET $S3_BUCKET_PATH \
  --exclude "*.html" --exclude "*.webmanifest" --exclude "p/*" \
  --delete --acl public-read

echo "Deploying to EC2."
rsync -avP --delete-excluded \
  --include="*.html" --include="*.webmanifest" \
  --exclude="p" --include="*/" --exclude="*" \
  --rsync-path="mkdir -p $EC2_REMOTE_PATH && rsync" \
  -e "ssh -o StrictHostKeyChecking=no" $TARGET/. $EC2_REMOTE_ADDR:$EC2_REMOTE_PATH

echo "getting rid of empty directories generated by rsync."
ssh $EC2_REMOTE_ADDR "find $EC2_REMOTE_PATH -type d -empty -delete"
