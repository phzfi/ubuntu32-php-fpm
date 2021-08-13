#!/bin/bash
VERSION=$1
USER=$2
PASSWORD=$3
BRANCH=$4

if [ -z "$VERSION" ]; then
  echo "Usage: ./build.sh <version>, e.g. ./build.sh latest user password php-version"
  exit 1
fi
if [ -z "$USER" ]; then
  echo "Usage: ./build.sh <version>, e.g. ./build.sh latest user password php-version"
  exit 1
fi
if [ -z "$PASSWORD" ]; then
  echo "Usage: ./build.sh <version>, e.g. ./build.sh latest user password php-version"
  exit 1
fi
if [ -z "$BRANCH" ]; then
  echo "Usage: ./build.sh <version>, e.g. ./build.sh latest user password php-version"
  exit 1
fi

#login to docker hub
docker login -u $USER -p $PASSWORD

IMAGE=phzfi/ubuntu32-php-fpm:$BRANCH-$VERSION
LATEST=phzfi/ubuntu32-php-fpm:$BRANCH-latest
echo "Building $IMAGE"

docker build -t $IMAGE -f Dockerfile-$BRANCH . --no-cache
docker tag $IMAGE $IMAGE
docker tag $IMAGE $LATEST
docker push $IMAGE
docker push $LATEST

