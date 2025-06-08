#!/bin/sh

if [ "$(whoami)" = 'root' ]; then
	echo 'up.sh: please run this as your regular user (phz)'
	exit 1
fi

docker compose up -d
