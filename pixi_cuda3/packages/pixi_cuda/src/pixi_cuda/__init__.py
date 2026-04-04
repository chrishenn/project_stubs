import torch
from torch import Tensor

import importlib.util

# install the .so as if it were a python package named "csrc", and use the package name to find the .so file
torch.ops.load_library(importlib.util.find_spec("csrc").origin)
ext_ns = getattr(torch.ops, "ns")


# install the .so directly into the pixi_cuda src files, and find by name
# torch.ops.load_library(str(next(iter(Path(__file__).parent.glob("*.so")))))
# ext_ns = getattr(torch.ops, "ns")


def myfn(inpt: Tensor) -> tuple[Tensor, Tensor]:
    """It's convenient to flatten out this torch.ops.ns.default access to expose from the package. We can also provide
    useful type hints, obviating stub files"""
    return ext_ns.myfn.default(inpt)


__all__ = ["myfn"]
