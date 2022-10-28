#! /bin/sh

/usr/bin/mc config host add <application-name> http://minio:9000 minio 2NVQWHvTT73XMgqapGchy6yAtwHezMZn;
/usr/bin/mc mb <application-name>/<application-name>-development;

# If you need your bucket to be public, uncomment this line
# /usr/bin/mc policy set public <application-name>/<application-name>-development;
