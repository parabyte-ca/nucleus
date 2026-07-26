#!/bin/bash
set -e

PROJECT="nucleus-api"
VERSION=$(cat VERSION 2>/dev/null || echo "latest")
PORT=8181
CONTAINER_NAME=nucleus-api

echo "Setting up $PROJECT v$VERSION..."

docker build -t parabyte-ca/$PROJECT:$VERSION -t parabyte-ca/$PROJECT:latest .

docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

docker run -d \
  --name $CONTAINER_NAME \
  --restart unless-stopped \
  -p $PORT:8000 \
  parabyte-ca/$PROJECT:latest

echo "$PROJECT is running on port $PORT"
