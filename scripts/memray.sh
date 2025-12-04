#!/bin/bash
# shellcheck disable=SC2317

mode_live() {
	## run memray with live graph
	#	memray run --live -m pytest "$1"
	memray run --live -m unittest "$1"
}

mode_flame() {
	## generate flame binfile, then generate webpage html from it
	python -m memray run -o flame.bin "$1"
	python -m memray flamegraph flame.bin
}

mode_pytest() {
	## run pytest and print memray mem usage summary
	# (prints blank right now. not sure why)
	pytest --memray --disable-warnings -s "$1"
}

main() {
	declare pytest_target=$1
	shift
	declare Mode=${1:-live}
	shift

	# not needed? not sure why
	scriptdir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]:-$0}")")
	. "$scriptdir/pypath.sh"

	if [[ -z $Mode ]] || ! declare -F "mode_$Mode" >/dev/null; then
		cat <<-'EOF' >&2
			Usage: ./memray.sh <pytest_target> [<mode>:default `live`]
			Usage: ./memray.sh <unittest_target> [<mode>:default `live`]

			Example: ./memray.sh src/tests/experiments/exp_ubuntu/ubuntu_igst.py::UbuntuIngestDataExperiments::test_1
			Example: ./memray.sh experiments.exp_ubuntu.ubuntu2.ubuntu_test.UbuntuExpIngesterDataExperiments.test_dump_data

			Modes:
			    live
			    flame
			    pytest
		EOF
		exit 1
	fi

	"mode_$Mode" "$pytest_target"
}

main "$@"
exit
