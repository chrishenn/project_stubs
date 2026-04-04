import torch
from torch import Tensor

import importlib.util

torch.ops.load_library(importlib.util.find_spec("pixi_cuda_c").origin)
ext_ns = getattr(torch.ops, "ns")


def myfn(inpt: Tensor) -> tuple[Tensor, Tensor]:
    """We can add type hints here, obviating stub files"""
    return ext_ns.myfn.default(inpt)


__all__ = ["myfn"]
