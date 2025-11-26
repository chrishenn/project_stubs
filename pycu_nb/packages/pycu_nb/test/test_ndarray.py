import numpy as np
import torch as t
from torch import Tensor

from pycu_nb import myfn_cpu, inspect, myfn_gpu


# if your nanobind fn returns a dlpack capsule, you can just convert with torch.from_dlpack:
# outpt = from_dlpack(outpt)


def test_cpu() -> None:
    # the cpu implementation adds one to the input
    cpu: Tensor = t.randint(100000, size=[100], dtype=t.int)
    outpt = myfn_cpu(cpu)
    assert (cpu + 1).eq(outpt).sum() == cpu.size(0)
    print("\nCPU: SUCCESS")


def test_gpu() -> None:
    # the gpu implementation subtracts one from the input
    gpu: Tensor = t.randint(100000, size=[100], dtype=t.int).to(0)
    outpt = myfn_gpu(gpu)
    assert (gpu - 1).eq(outpt).sum() == gpu.size(0)
    print("\nGPU: SUCCESS")


def test_versions() -> None:
    print()
    print("numpy:\t", np.__version__)
    print("torch:\t", t.__version__)
    print("torch cmake prefix:\t", t.utils.cmake_prefix_path)
    print("torch cuda avail:\t", t.cuda.is_available())
    print()


def test_inspect():
    inspect(np.array([[1, 2, 3], [3, 4, 5]], dtype=np.float32))
    print()
    inspect(t.zeros([4, 2], dtype=t.float32))


if __name__ == "__main__":
    test_versions()
    test_cpu()
    test_gpu()
