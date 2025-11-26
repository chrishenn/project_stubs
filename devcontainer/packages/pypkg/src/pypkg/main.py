import torch as t
import numpy as np


def test_versions() -> None:
    print()
    print("numpy:\t", np.__version__)
    print("torch:\t", t.__version__)
    print("torch cmake prefix:\t", t.utils.cmake_prefix_path)
    print("torch cuda avail:\t", t.cuda.is_available())
    print()


if __name__ == "__main__":
    test_versions()
