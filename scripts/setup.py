from setuptools import setup
from torch.utils.cpp_extension import BuildExtension, CUDAExtension
import sys


# specify extension to build from command line with: --name=<extension name>


def main(argv):
    name = None
    for arg in argv:
        if arg.find("name") > 0:
            name = arg.split("=")[-1]
            sys.argv.remove(arg)

    if name is None:
        name = "frnn"
    print("building extension: ", name)

    if name == "frnn":
        setup(
            name="frnn",
            ext_modules=[
                CUDAExtension(
                    name="frnn_cuda",
                    sources=[
                        "frnn/frnn_bind_define.cpp",
                        "frnn/frnn_driver.cu",
                        "frnn/frnn_bin_kern.cu",
                        "frnn/frnn_bipart_kern.cu",
                        "frnn/scan.cu",
                    ],
                    extra_compile_args={
                        "cxx": ["-g"],
                        "nvcc": ["-Xcompiler", "-rdynamic", "-lineinfo", "-prec-sqrt=false"],
                    },
                )
            ],
            cmdclass={"build_ext": BuildExtension},
        )


if __name__ == "__main__":
    main(sys.argv)
