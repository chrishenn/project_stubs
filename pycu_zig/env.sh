#!/bin/bash

# usage:
# 	. env.sh
# 	source env.sh

function env_once() {
	proj="pycu_zig"

	source ~/spack/share/spack/setup-env.sh
	spack config add modules:prefix_inspections:lib64:[LD_LIBRARY_PATH]
	spack config add modules:prefix_inspections:lib:[LD_LIBRARY_PATH]
	spack -e . concretize
	spack -e . install
	spack env activate . -p
	uv venv --prompt $proj .venv
	#    source .venv/bin/activate
}

function env() {
	source ~/spack/share/spack/setup-env.sh
	spack env activate . -p
	#	source .venv/bin/activate
}

env
