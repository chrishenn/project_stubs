import os
from pathlib import Path

from setuptools import find_packages, setup
from torch.utils.cpp_extension import BuildExtension, CppExtension, CUDAExtension

ext_name = "ext"


def get_extensions():
    if debug_mode := (os.getenv("DEBUG", "0") == "1"):
        print("Compiling in debug mode")

    # use_cuda = os.getenv("USE_CUDA", "1") == "1"
    # use_cuda = use_cuda and torch.cuda.is_available() and CUDA_HOME is not None
    use_cuda = True
    ext_t = CUDAExtension if use_cuda else CppExtension

    extra_link_args = []
    extra_compile_args = {
        "cxx": ["-O3" if not debug_mode else "-O0", "-fdiagnostics-color=always"],
        "nvcc": ["-O3" if not debug_mode else "-O0"],
    }
    if debug_mode:
        extra_compile_args["cxx"].append("-g")
        extra_compile_args["nvcc"].append("-g")
        extra_link_args.extend(["-O0", "-g"])

    # ext = Path.cwd() / "ext"
    ext = Path("ext")
    src = list(ext.glob("*.cpp"))
    cu_src = list(ext.glob("*.cu"))

    if use_cuda:
        src += cu_src

    src = list(map(str, src))

    return [ext_t(f"{ext_name}._C", src, extra_compile_args=extra_compile_args, extra_link_args=extra_link_args)]


setup(
    name=ext_name,
    version="0.1.0",
    packages=find_packages(),
    ext_modules=get_extensions(),
    install_requires=["torch"],
    description="example",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="https://github.com/pytorch/extension-cpp",
    cmdclass={"build_ext": BuildExtension},
)

if __name__ == "__main__":
    setup()
