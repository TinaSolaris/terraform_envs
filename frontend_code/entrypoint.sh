#!/bin/sh
ROOT_DIR=/home/stud/static

sed -i 's|<BACKEND_URL>|'${BACKEND_URL}'|g' /home/stud/static/index.html

# Then execute the CMD passed to the Dockerfile
exec "$@"