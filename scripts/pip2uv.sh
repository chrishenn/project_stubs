#!/bin/bash
# shellcheck disable=SC2317

mode_sync() {
	uv pip sync \
		src/tests/test-requirements.txt \
		build/container-requirements.txt
}

mode_sync_exp() {
	uv pip sync \
		src/tests/test-requirements.txt \
		build/container-requirements.txt \
		src/tests/experiments/exp-requirements.txt
}

mode_create() {
	uv python install 3.11
	uv venv --python 3.11 .venv
	source .venv/bin/activate
	mode_sync
	mode_update_exp
}

mode_update_exp() {
	mode_sync
	uv pip compile \
		src/tests/experiments/exp-requirements.in \
		--no-annotate \
		--strip-extras \
		--universal \
		--output-file src/tests/experiments/exp-requirements.txt
	# uv pip compile keeps full hash, but pip-compile truncates hash to first 7 chars
	sed -i -e 's/7c5a45951ed0f213dcebb7bb7b812942e030e4e3/7c5a459/g' src/tests/experiments/exp-requirements.txt
	mode_sync_exp
}

mode_delete() {
	rm -rf .venv
}

main() {
	declare Mode=$1
	shift

	if [[ -z $Mode ]] || ! declare -F "mode_$Mode" >/dev/null; then
		cat <<-'EOF' >&2
			Usage: ./venv.sh <mode>

			Modes:
				create
				delete
				sync
				sync_exp
				update_exp
		EOF
		exit 1
	fi

	"mode_$Mode" "$@"
}

main "$@"
exit
