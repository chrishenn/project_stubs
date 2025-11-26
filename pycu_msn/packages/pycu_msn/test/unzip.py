#!/usr/bin/env python3
from pathlib import Path
import argparse

import tarfile
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
    fn: Path, outpath: str, strip_root: bool = True, overwrite: bool = False
):
    out_path = Path(outpath).expanduser().resolve()
    if out_path.is_dir() and not overwrite:
        return

    fn = Path(fn).expanduser().resolve()
    with ZipFile(fn) as z:
        z.extractall(out_path)

    if strip_root:
        striparchiveroot(out_path)


def extract_tar(fn: Path, outpath: Path, overwrite: bool = False):
    outpath = Path(outpath).expanduser().resolve()
    # need .resolve() in case intermediate relative dir doesn't exist
    if outpath.is_dir() and not overwrite:
        return

    fn = Path(fn).expanduser().resolve()
    if not fn.is_file():
        raise FileNotFoundError(fn)  # keep this, tarfile gives confusing error
    with tarfile.open(fn) as z:
        z.extractall(str(outpath.parent))


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("infile", help="compressed file to extract")
    p.add_argument("outpath", help="path to extract into")
    P = p.parse_args()

    infile = Path(P.infile)
    if infile.suffix.lower() in (".zip", ".whl"):
        extract_zip(infile, P.outpath)
    elif infile.suffix.lower() in (".tar", ".gz", ".bz2", ".xz"):
        extract_tar(infile, P.outpath)
    else:
        raise ValueError("Not sure how to decompress {}".format(infile))
