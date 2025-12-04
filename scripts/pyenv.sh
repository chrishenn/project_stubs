do_install_pyenv() {
	pyenv activate "$env_name"
	python -m pip install --upgrade pip
	python -m pip install 'pip-tools>=7.3.0'
	pip-sync \
		src/tests/test-requirements.txt \
		src/tests/experiments/exp-requirements.txt \
		build/container-requirements.txt
}

create_pyenv() {
	apt_install
	"$scriptdir/pyenv_install.sh"
	source "$HOME/.bashrc"
	pyenv install 3.11
	pyenv virtualenv 3.11 "$env_name"
}

delete_pyenv() {
	pyenv uninstall "$env_name" -y
}
