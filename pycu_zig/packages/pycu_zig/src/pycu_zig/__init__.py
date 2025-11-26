import torch

from torch import Tensor

# torch.ops.load_library(one((Path(__file__).parent / "build").glob("_C*.so")))
# """filename "_C.<python><ver><platform>.so" is hardcoded in CMakeLists.txt"""
#
#
# ext_ns = getattr(torch.ops, Path(__file__).parent.name)
# """The extension's namespace is bound onto torch.ops.<name>, so multiple extensions must not use the same namespace name
# I've manually set the extension to have the same name as the package"""
#
#
# def myfn(inpt: Tensor) -> tuple[Tensor, Tensor]:
#     """It's convenient to flatten out this torch.ops.ns.default access to expose from the package. We can also provide
#     useful type hints, obviating stub files"""
#     return ext_ns.myfn.default(inpt)

from ._C import hello

__all__ = ["hello"]
