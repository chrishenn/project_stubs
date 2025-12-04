#!/bin/bash
# shellcheck disable=SC2317

scriptdir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]:-$0}")")
. "$scriptdir/pypath.sh"
. "$scriptdir/cri.sh"

mode_start_db() {
	cri start pg_docker
}

mode_run_db() {
	cri run \
		-d \
		--name pg_docker \
		--network host \
		-p 5432:5432 \
		-e POSTGRES_USER="root" \
		-e POSTGRES_PASSWORD="1234" \
		-e POSTGRES_DB=pg_docker \
		docker.io/library/postgres:14

	sleep 3
	python "$scriptdir/pg_upgrade_adduser.py"
}

mode_reset_db() {
	cri rm -f pg_docker
	rm -rf /var/lib/postgres/data/*
	mode_run_db
}

mode_run_backend() {
	cri run \
		--name project \
		--rm \
		--network=bridge \
		-p 5001:5000 \
		-e CORS_ORIGINS="http://localhost:3000" \
		-e CLIENT_URL="http://localhost:3000/" \
		-e NEXT_PUBLIC_API_URL="http://localhost:5001" \
		-e NEXTAUTH_URL="http://localhost:5001" \
		-e CALLBACK_AUTH_URL="http://localhost:5001" \
		-v "$(pwd)":/mnt/work \
		dev-project
}

mode_connect_db() {
	psql -U root -h 127.0.0.1 -p 6543 -d pg_docker
}

main() {
	declare Mode=$1
	shift

	if [[ -z $Mode ]] || ! declare -F "mode_$Mode" >/dev/null; then
		cat <<-'EOF' >&2
			Usage: ./pod_run.sh <mode>

			Modes:
			    run_db
			    run_portal
			    run_backend
			    start_db
			    reset_db
		EOF
		exit 1
	fi

	"mode_$Mode" "$@"
}

main "$@"
exit
