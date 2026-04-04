import re

import sh
from cytoolz import curry
from cytoolz.curried import filter, map

quirks = {"flask-accepts": "flask-accepts @ git+https://github.com/repo/hash"}


def print_pkgs() -> None:
    # pip list; slice the two header lines
    pkgs = sh.pip("list").split("\n")[2:]

    # filter lines that are just an empty string
    pkgs = filter(bool, pkgs)

    # "name   version   othercrap" -> ("name", "version")
    def namever2tup(pkg: str) -> tuple:
        return tuple(re.split(r"(\s)+", pkg)[slice(0, 3, 2)])

    pkgs = map(namever2tup, pkgs)

    # [("black", "24.4.2"), ...] -> ["black==24.4.2", ...]
    pkgs = map(lambda kv: f"{kv[0]}=={kv[1]}", pkgs)

    @curry
    def match2quirk(pattern_: str, replace_: str, name_ver: str) -> str:
        return replace_ if re.search(pattern_, name_ver, re.IGNORECASE) else name_ver

    for pattern, replace in quirks.items():
        pkgs = map(match2quirk(pattern, replace), pkgs)

    # black==24.4.2 -> "black==24.4.2",
    pkgs = map(lambda v: f'"{v}",', pkgs)

    print(*list(pkgs), sep="\n")


if __name__ == "__main__":
    print_pkgs()
