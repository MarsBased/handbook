#! /bin/sh

/usr/bin/mc config host add <application-name> http://minio:9000 minio 2NVQWHvTT73XMgqapGchy6yAtwHezMZn;
/usr/bin/mc mb <application-name>/<application-name>-development;
