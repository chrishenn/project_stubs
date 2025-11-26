sdir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]:-$0}")")

eval "$($HOME/.local/bin/mise activate bash)"
eval "$(pixi shell-hook --manifest-path $sdir/pixi.toml)"
