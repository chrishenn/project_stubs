import numpy as np
import torch
from torch import Tensor

# from pycu_bzl import myfn


torch.ops.load_library(
    "/home/chris/Projects/pycu_bzl/packages/pycu_bzl/bazel-bin/_C.so"
)
# torch.ops.load_library("/home/chris/Projects/pycu_bzl/packages/pycu_bzl/src/pycu_bzl/_C.so")

# torch.ops.load_library(one(Path(__file__).parent.glob("_C*.so")))
"""filename "_C.<python><ver><platform>.so" is hardcoded in CMakeLists.txt"""


ext_ns = getattr(torch.ops, "pycu_skit")
"""The extension's namespace is bound onto torch.ops.<name>, so multiple extensions must not use the same namespace name
I've manually set the extension to have the same name as the package"""


def myfn(inpt: Tensor) -> tuple[Tensor, Tensor]:
    """It's convenient to flatten out this torch.ops.ns.default access to expose from the package. We can also provide
    useful type hints, obviating stub files"""
    return ext_ns.myfn.default(inpt)


def test_cpu() -> None:
    # the cpu implementation adds one to the input
    cpu: Tensor = torch.randint(100000, size=[100], dtype=torch.int)
    inpt, outpt = myfn(cpu)
    assert (inpt + 1).eq(outpt).sum() == inpt.size(0)
    print("\nCPU: SUCCESS")


def test_gpu() -> None:
    # the gpu implementation subtracts one from the input
    gpu: Tensor = torch.randint(100000, size=[100], dtype=torch.int).to(0)
    inpt, outpt = myfn(gpu)
    assert (inpt - 1).eq(outpt).sum() == inpt.size(0)
    print("\nGPU: SUCCESS")


def test_versions() -> None:
    print()
    print("numpy:\t", np.__version__)
    print("torch:\t", torch.__version__)
    print("torch cmake prefix:\t", torch.utils.cmake_prefix_path)
    print("torch cuda avail:\t", torch.cuda.is_available())
    print()


if __name__ == "__main__":
    test_versions()
    test_cpu()
    test_gpu()
