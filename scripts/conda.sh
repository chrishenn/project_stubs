#!/bin/bash
# shellcheck disable=SC2317

scriptdir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]:-$0}")")

env_name="venv"

do_install_conda() {
	conda run -n "$env_name" python -m pip install --upgrade pip
	conda run -n "$env_name" python -m pip install pip-tools
	conda run -n "$env_name" pip-sync \
		src/tests/test-requirements.txt \
		src/tests/experiments/exp-requirements.txt
}

create_conda() {
	# most are needed pkg deps to build project pip python, some are general pkgs
	apt_install
	conda env create -f "$env_name.yml"
	do_install
}

update_conda() {
	conda env update -f "$env_name.yml"
	do_install
}

update_base_conda() {
	conda update -n base -c defaults conda -y
}

delete_conda() {
	if [ "$CONDA_DEFAULT_ENV" = "$env_name" ]; then
		echo "can't delete active conda env. run 'conda deactivate' first"
		exit 1
	fi
	conda remove --name "$env_name" --all -y
}
