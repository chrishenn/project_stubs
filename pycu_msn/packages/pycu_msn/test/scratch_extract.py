#!/usr/bin/env python3
from pathlib import Path

from zipfile import ZipFile


def striparchiveroot(out_path: Path):
    extracted = list(out_path.glob("*"))
    if len(extracted) != 1:
        return

    for path in list(out_path.rglob("*/**"))[1:]:
        tgt = Path(*path.relative_to(out_path).parts[1:])

        ptgt = out_path / tgt
        if not ptgt.exists():
            path.rename(ptgt)

    extracted[0].rmdir()


def extract_zip(
    fn: str, outpath: str, strip_root: bool = True, overwrite: bool = False
):
    out_path = Path(outpath).expanduser().resolve()
    if out_path.is_dir() and not overwrite:
        return

    fn = Path(fn).expanduser().resolve()
    with ZipFile(fn) as z:
        z.extractall(out_path)

    if strip_root:
        striparchiveroot(out_path)


def test_extract():
    fn = "libtorch.zip"
    extract_zip(fn, "src")
