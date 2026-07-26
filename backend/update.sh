#!/bin/bash
set -e

PROJECT="nucleus-api"
CONTAINER_NAME=nucleus-api
PORT=8181

echo "Updating $PROJECT..."

git pull

docker build -t parabyte-ca/$PROJECT:latest .

docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME

docker run -d \
  --name $CONTAINER_NAME \
  --restart unless-stopped \
  -p $PORT:8000 \
  parabyte-ca/$PROJECT:latest

echo "Update complete."
