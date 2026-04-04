#!/bin/bash
# shellcheck disable=SC2317

map0=('/mnt/f' '//192.168.1.15/f')
map1=('/mnt/h' '//192.168.1.15/h')
map2=('/mnt/k' '//192.168.1.15/k')
map3=('/mnt/debug_server' '//192.168.1.46/c')
map4=('/mnt/build_server' '//192.168.1.240/c')
map4=('/mnt/node_01' '//192.168.1.40/c')

declare -A remotes=(
	['storage_f']=map0
	['storage_h']=map1
	['storage_k']=map2
	['debug_server']=map3
	['build_server']=map4
)

remote_pingable() {
	declare remote_host=$1

	if ping -c 1 "$remote_host" &>/dev/null; then
		echo "host up: $remote_host responded to ping"
		true
		return
	else
		echo "host down: $remote_host did not respond"
		false
		return
	fi
}

point_mounted() {
	declare mnt=$1

	if mountpoint -q "$mnt"; then
		echo "$mnt mounted"
		true
		return
	else
		echo "no remote mounted at: $mnt"
		false
		return
	fi
}

do_mount() {
	declare mnt=$1
	declare remote=$2
	declare user=${3:-chris}

	# if mountpoint dir not exist, make it
	[ -d "$mnt" ] || mkdir "$mnt"

	# if there's already a remote mounted at this target, exit success
	point_mounted "$mnt" && return 0

	# if remote not reachable, exit failure
	local remote_ip
	remote_ip=$(echo "$remote" | cut -d "/" -f 3)
	remote_pingable "$remote_ip" || return 1

	echo "mounting $remote $mnt"
	local opts
	opts=(
		"$remote"
		"$mnt"
		-t cifs
		-o "user=$user,file_mode=0777,dir_mode=0777,uid=1000,gid=1000,vers=3.11,noauto,noperm,noatime,iocharset=utf8"
	)
	if [ "$EUID" ]; then
		mount "${opts[@]}"
	else
		sudo mount "${opts[@]}"
	fi
}

do_umount() {
	declare mnt=$1

	echo "unmounting $mnt"
	sudo umount "$mnt"
}

do_attach() {
	shift
	declare remote=${1}
	shift
	declare user=${1:-chris}

	local remote_ip
	remote_ip=$(echo "$remote" | cut -d "/" -f 3)
	remote_pingable "$remote_ip" || return 1

	echo "ssh attaching to: $remote_ip with user: $user"
	ssh -t "$user@$remote_ip" "cd C:\repo & powershell"
}

do_for_remotes() {
	declare Mode=${1}
	shift
	declare mount_name=${1:-all}
	shift
	declare -n mapping

	echo "running | mode: $Mode | target: $mount_name | other_args: $*"

	if [ "$mount_name" == "all" ]; then
		for mapping in "${remotes[@]}"; do
			"do_$Mode" "${mapping[0]}" "${mapping[1]}" "$@"
		done
	elif [ "${remotes[$mount_name]+found}" ]; then
		mapping="${remotes[$mount_name]}"
		"do_$Mode" "${mapping[0]}" "${mapping[1]}" "$@"
	else
		echo "error: unknown mount_name: $mount_name"
		return 1
	fi
}

mode_mount() {
	do_for_remotes "$@"
}

mode_umount() {
	do_for_remotes "$@"
}

mode_push() {
	shift
	do_for_remotes mount "$@" || return 1
	do_for_remotes push "$@"
}

mode_attach() {
	declare mount_name=${2:-all}

	if [ "$mount_name" == "all" ]; then
		echo "error: attach to a mount name that's not empty or all"
		exit 1
	fi
	do_for_remotes "$@"
}

main() {
	declare Mode=$1
	if [[ -z $Mode ]] || ! declare -F "mode_$Mode" >/dev/null; then
		cat <<-'EOF' >&2
			Usage: buildnode.sh <mode> [args]...

			Modes:
			    mount
			    push

			            Example:
			                ./buildnode.sh mount
			                ./buildnode.sh mount all
			                ./buildnode.sh mount debug_server
			                ./buildnode.sh umount debug_server
			                ./buildnode.sh attach build_server
			                ./buildnode.sh attach build_server chris
		EOF
		exit 1
	fi

	"mode_$Mode" "$@"
}

main "$@"
echo -e "\n exited with code: $?"
exit
