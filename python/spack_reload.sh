#!/usr/bin/env bash

# Reload the spack environment defined in ./spack.yml
# usage:
# 	. spack_reload.sh

despacktivate
spack env activate . -p
