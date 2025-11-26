from pathlib import Path

import torch
from torch import Tensor


so = list((Path(__file__).parent / "build").glob("*_C*.so"))
assert len(so) == 1, f"Error loading shared-object library; expected 1 .so file, but found: {len(so)}"

torch.ops.load_library(str(so[0]))
"""filename "_C.<python><ver><platform>.so" is hardcoded in CMakeLists.txt"""


ext_ns = getattr(torch.ops, Path(__file__).parent.name)
"""The extension's namespace is bound onto torch.ops.<name>, so multiple extensions must not use the same namespace name
I've manually set the extension to have the same name as the package"""


def myfn(inpt: Tensor) -> tuple[Tensor, Tensor]:
    """It's convenient to flatten out this torch.ops.ns.default access to expose from the package. We can also provide
    useful type hints, obviating stub files"""
    return ext_ns.myfn.default(inpt)


__all__ = ["myfn"]
