import os
import torch
from importlib.resources import files
from dotenv import load_dotenv

load_dotenv(override=True)
PKG_NAME = os.getenv("PKG_NAME")
MOD_NAME = os.getenv("MOD_NAME")
OPS_NAME = os.getenv("OPS_NAME")

pkg = files(MOD_NAME)
so_path = pkg.joinpath("lib" + MOD_NAME + ".so")
torch.ops.load_library(so_path)


def get(*args, **kwargs):
    func_string = "torch.ops." + OPS_NAME + "." + MOD_NAME
    return eval(func_string)(*args, **kwargs)
