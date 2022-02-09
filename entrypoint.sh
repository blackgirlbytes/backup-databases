#!/usr/bin/env bash

TIME=$(date +%b-%d-%y-%H%M)
FILENAME="backup-$TIME.tar.gz"
TMP_DIR=/tmp

REPLACE=$(
  cat <<END
import sys
import re

for line in sys.stdin:
    line = re.sub(r'^\(', '', line)
    line = re.sub(r'\)$', '', line)
    sys.stdout.write(line)
END
)

aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY

set echo off
mysql -u admin_rizel -p --database=employees --host=demo-actions-db.cbou4ufhnwpk.us-east-1.rds.amazonaws.com --port=3306 --batch -e "select * from people " | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' > "$TMP_DIR/$database.sql"
tar -cpzf "$TMP_DIR/$database-$FILENAME" "$TMP_DIR/$database.sql"
set echo on

printf "Uploading to S3...\n"
aws s3 cp "$TMP_DIR/$database-$FILENAME" "s3://$S3_BUCKET_NAME/$S3_FOLDER/$database-$FILENAME"
printf "Uploaded to S3.\n"

printf "Cleaning up...\n"
rm -rf "$TMP_DIR/$database-$FILENAME"
printf "Cleaned up.\n"
