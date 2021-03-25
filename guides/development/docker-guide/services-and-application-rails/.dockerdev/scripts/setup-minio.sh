#! /bin/sh

echo "Waiting for Minio to start..."
sleep 5
/scripts/create-bucket.sh
