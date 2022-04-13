#!/bin/sh

ENV=$1
PHP_VERSION=$2
VERSION=$3
USER=$4
PASSWORD=$5

usage() {
	echo 'Usage: ./docker/build.sh <dev|prod> <php-version> [version] [user] [password], e.g. ./docker/build.sh prod 7.4 latest user password'
	exit 2
}

# argument parsing
[ $# -lt 2 ] && usage
case "$ENV" in
dev) ;; # we can ignore extra arguments
prod) [ $# -ne 5 ] && usage ;;
*) usage
esac

# use phz prefix for dev images and phzfi for prod images
if [ "$ENV" = 'dev' ]; then
	IMAGE=phz/ubuntu32-php-fpm:$PHP_VERSION-dev
else # prod
	IMAGE=phzfi/ubuntu32-php-fpm:$PHP_VERSION-$VERSION
	LATEST=phzfi/ubuntu32-php-fpm:$PHP_VERSION-latest
fi

echo "Building ${ENV} ${IMAGE}"
docker build --platform linux/386 -t "$IMAGE" -f "Dockerfile-${PHP_VERSION}" --no-cache .
#docker build -t "$IMAGE" -f Dockerfile --build-arg PHP_VERSION=$PHP_VERSION --no-cache .
#docker build --platform linux/386 -t "$IMAGE" -f Dockerfile --build-arg PHP_VERSION=$PHP_VERSION --no-cache .

if [ "$ENV" = 'prod' ]; then
	docker login -u "$USER" -p "$PASSWORD"
	docker tag "$IMAGE" "$IMAGE"
	docker tag "$IMAGE" "$LATEST"
	docker push "$IMAGE"
	docker push "$LATEST"
fi
