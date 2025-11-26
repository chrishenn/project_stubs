#!/bin/bash

PLAT="manylinux2014_x86_64"
DOCKER_IMAGE="sameli/manylinux2014_x86_64_cuda_11"

## this path /home/chris/Documents has the appropriate libtorch folder in it
## and optionally the cudnn .rpm install file
docker run --rm -e PLAT=$PLAT -v $(pwd):/io --mount type=bind,source="/home/chris/Documents/",target="/home/chris/Documents" $DOCKER_IMAGE /io/build-wheels.sh
