import numpy as np
import torch as t

from pixi_cuda import myfn


def test_cpu() -> None:
    # the cpu implementation adds one to the input
    cpu: t.Tensor = t.randint(100000, size=[100], dtype=t.int)
    inpt, outpt = myfn(cpu)
    assert (cpu + 1).eq(outpt).sum() == inpt.size(0)
    print("\nCPU: SUCCESS")


def test_gpu() -> None:
    # the gpu implementation subtracts one from the input
    gpu: t.Tensor = t.randint(100000, size=[100], dtype=t.int).to(0)
    inpt, outpt = myfn(gpu)
    assert (gpu - 1).eq(outpt).sum() == inpt.size(0)
    print("\nGPU: SUCCESS")


def test_versions() -> None:
    print()
    print("numpy:\t", np.__version__)
    print("torch:\t", t.__version__)
    print("torch cmake prefix:\t", t.utils.cmake_prefix_path)
    print("torch cuda avail:\t", t.cuda.is_available())
    print()


if __name__ == "__main__":
    test_versions()
    test_cpu()
    test_gpu()
