#!/bin/bash

function spack_once {
	# manual add LD_LIBRARY_PATH for cuda, as this is not automatically handled by spack anymore
	spack config add modules:prefix_inspections:lib64:[LD_LIBRARY_PATH]
	spack config add modules:prefix_inspections:lib:[LD_LIBRARY_PATH]
}

function env_once() {
	# spack init is assumed in current shell (add to .bashrc)
	spack -e . concretize --fresh --force
	spack -e . install
	spack env activate . -p
}

function env() {
	# uv venv init is assumed in current shell (done by IDE)
	spack env activate . -p
}

env
