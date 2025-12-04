#!/usr/bin/env -S uv run

from os import environ
from typing import TYPE_CHECKING

from aenum import StrEnum

from util.paths import PATHS


if TYPE_CHECKING:
    from pathlib import Path


class EVar(StrEnum):
    _init_ = ("value", "default")

    EDATA_FILES = "EDATA_FILES", f"{environ['HOME']}/Documents/data/"


def link_data() -> None:
    if not (tgt := environ.get(EVar.EDATA_FILES.value)):
        print(
            f"Env var not set: `{EVar.EDATA_FILES.value}`\n\tfalling back to default: `{EVar.EDATA_FILES.default}`"
        )

        if not (tgt := EVar.EDATA_FILES.default):
            msg = f"\tNo value for lnk target. Set env `{EVar.EDATA_FILES.value}` or provide a default"
            raise ValueError(msg)

    lnk: Path = PATHS.edata_files
    print(f"creating symlink:\n\ttarget: {tgt}\n\tsource: {lnk}")

    try:
        lnk.symlink_to(tgt, target_is_directory=True)
    except FileExistsError as e:
        e.add_note(
            f"link_data():\n\tcreate symlink failed\n\ttarget `{tgt}` already exists"
        )
        raise
    except NotImplementedError as e:
        e.add_note(
            "link_data():\n\tcreate symlink failed\n\t`symlink` not implemented for os"
        )
        raise
    except Exception as e:
        e.add_note("link_data():\n\traising unknown exception")
        raise


if __name__ == "__main__":
    link_data()
