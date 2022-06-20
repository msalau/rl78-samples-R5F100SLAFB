#!/bin/sh

set -e
set -x

docker run --rm -it -v "$(pwd):/src" msalau/rl78-elf-gcc:latest make "$@"
