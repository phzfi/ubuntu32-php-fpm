#!/bin/bash
VERSION=$1
USER=$2
PASSWORD=$3

if [ -z "$VERSION" ]; then
  echo "Usage: ./build.sh <version>, e.g. ./build.sh latest user password"
  exit 1
fi

#login to docker hub
docker login -u $USER -p $PASSWORD

IMAGE=phzfi/ubuntu32-php-fpm:$VERSION
LATEST=phzfi/ubuntu32-php-fpm:latest
echo "Building $IMAGE"

docker build -t $IMAGE -f Dockerfile . --no-cache
docker tag $IMAGE $IMAGE
docker tag $IMAGE $LATEST
docker push $IMAGE
docker push $LATEST

