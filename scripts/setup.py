from setuptools import setup
from torch.utils.cpp_extension import BuildExtension, CUDAExtension
import sys

## specify extension to build from command line with: --name=<extension name>


def main(argv):
    name = None
    for arg in argv:
        if arg.find("name") > 0:
            name = arg.split("=")[-1]
            sys.argv.remove(arg)

    if name is None:
        name = "frnn"
    print("building extension: ", name)

    ## /frnn
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
                        "nvcc": [
                            "-Xcompiler",
                            "-rdynamic",
                            "-lineinfo",
                            "-prec-sqrt=false",
                        ],
                    },
                )
            ],
            cmdclass={"build_ext": BuildExtension},
        )

    ## /frnn_bipart
    elif name == "frnn_bipart":
        setup(
            name="frnn_bipart",
            ext_modules=[
                CUDAExtension(
                    name="frnn_bipart_cuda",
                    sources=[
                        "frnn_bipart/frnn_bipart_bind_define.cpp",
                        "frnn_bipart/frnn_bipart_driver.cu",
                        "frnn_bipart/frnn_bin_kern.cu",
                        "frnn_bipart/frnn_bipart_kern.cu",
                        "frnn_bipart/scan.cu",
                    ],
                    extra_compile_args={
                        "cxx": ["-g"],
                        "nvcc": [
                            "-Xcompiler",
                            "-rdynamic",
                            "-lineinfo",
                            "-prec-sqrt=false",
                        ],
                    },
                )
            ],
            cmdclass={"build_ext": BuildExtension},
        )

    ## /frnn_opt
    elif name == "frnn_opt":
        """frnn_optimized version implements differnet interface with different sizes of pts. NOT a drop-in replacement."""
        setup(
            name="frnn_opt",
            ext_modules=[
                CUDAExtension(
                    name="frnn_cuda",
                    sources=[
                        "frnn_opt/frnn_bind_define.cpp",
                        "frnn_opt/frnn_driver.cu",
                        "frnn_opt/frnn_bin_kern.cu",
                        "frnn_opt/frnn_bipart_kern.cu",
                        "frnn_opt/scan.cu",
                    ],
                    extra_compile_args={
                        "cxx": ["-g"],
                        "nvcc": [
                            "-Xcompiler",
                            "-rdynamic",
                            "-lineinfo",
                            "-prec-sqrt=false",
                        ],
                    },
                )
            ],
            cmdclass={"build_ext": BuildExtension},
        )

    ## /grid_bin
    elif name == "grid_bin":
        setup(
            name="grid_bin",
            ext_modules=[
                CUDAExtension(
                    name="grid_bin_cuda",
                    sources=[
                        "grid_bin/grid_bin_define.cpp",
                        "grid_bin/grid_bin_driver.cu",
                    ],
                    extra_compile_args={
                        "cxx": ["-g"],
                        "nvcc": [
                            "-Xcompiler",
                            "-rdynamic",
                            "-lineinfo",
                            "-prec-sqrt=false",
                        ],
                    },
                )
            ],
            cmdclass={"build_ext": BuildExtension},
        )

    elif name == "ring_bin":
        setup(
            name="ring_bin",
            ext_modules=[
                CUDAExtension(
                    name="ring_bin_cuda",
                    sources=[
                        "grid_bin/ring_bin_define.cpp",
                        "grid_bin/ring_bin_driver.cu",
                    ],
                    extra_compile_args={
                        "cxx": ["-g"],
                        "nvcc": [
                            "-Xcompiler",
                            "-rdynamic",
                            "-lineinfo",
                            "-prec-sqrt=false",
                        ],
                    },
                )
            ],
            cmdclass={"build_ext": BuildExtension},
        )

    elif name == "one_bin":
        setup(
            name="one_bin",
            ext_modules=[
                CUDAExtension(
                    name="one_bin_cuda",
                    sources=[
                        "grid_bin/one_bin_define.cpp",
                        "grid_bin/one_bin_driver.cu",
                    ],
                    extra_compile_args={
                        "cxx": ["-g"],
                        "nvcc": [
                            "-Xcompiler",
                            "-rdynamic",
                            "-lineinfo",
                            "-prec-sqrt=false",
                        ],
                    },
                )
            ],
            cmdclass={"build_ext": BuildExtension},
        )

    ## /edge_bin
    elif name == "edge_bin":
        setup(
            name="edge_bin",
            ext_modules=[
                CUDAExtension(
                    name="edge_bin_cuda",
                    sources=[
                        "edge_bin/edge_bin_define.cpp",
                        "edge_bin/edge_bin_driver.cu",
                    ],
                    extra_compile_args={
                        "cxx": ["-g"],
                        "nvcc": [
                            "-Xcompiler",
                            "-rdynamic",
                            "-lineinfo",
                            "-prec-sqrt=false",
                        ],
                    },
                )
            ],
            cmdclass={"build_ext": BuildExtension},
        )

    elif name == "edge_min":
        setup(
            name="edge_min",
            ext_modules=[
                CUDAExtension(
                    name="edge_min_cuda",
                    sources=[
                        "edge_bin/edge_min_define.cpp",
                        "edge_bin/edge_min_driver.cu",
                    ],
                    extra_compile_args={
                        "cxx": ["-g"],
                        "nvcc": [
                            "-Xcompiler",
                            "-rdynamic",
                            "-lineinfo",
                            "-prec-sqrt=false",
                        ],
                    },
                )
            ],
            cmdclass={"build_ext": BuildExtension},
        )

    elif name == "edge_prune":
        setup(
            name="edge_prune",
            ext_modules=[
                CUDAExtension(
                    name="edge_prune_cuda",
                    sources=[
                        "edge_bin/edge_prune_define.cpp",
                        "edge_bin/edge_prune_driver.cu",
                    ],
                    extra_compile_args={
                        "cxx": ["-g"],
                        "nvcc": [
                            "-Xcompiler",
                            "-rdynamic",
                            "-lineinfo",
                            "-prec-sqrt=false",
                        ],
                    },
                )
            ],
            cmdclass={"build_ext": BuildExtension},
        )

    ## /coll_nebs
    elif name == "coll_nebs":
        setup(
            name="coll_nebs",
            ext_modules=[
                CUDAExtension(
                    name="coll_nebs_cuda",
                    sources=[
                        "coll_nebs/coll_nebs_bind_define.cpp",
                        "coll_nebs/coll_nebs_driver.cu",
                        "coll_nebs/frnn_bin_kern.cu",
                        "coll_nebs/frnn_bipart_kern.cu",
                        "coll_nebs/scan.cu",
                    ],
                    extra_compile_args={
                        "cxx": ["-g"],
                        "nvcc": [
                            "-Xcompiler",
                            "-rdynamic",
                            "-lineinfo",
                            "-prec-sqrt=false",
                        ],
                    },
                )
            ],
            cmdclass={"build_ext": BuildExtension},
        )

    ## /merge_cuda
    elif name == "merge_cuda":
        setup(
            name="merge_cuda",
            ext_modules=[
                CUDAExtension(
                    name="oomerge_cuda",
                    sources=[
                        "merge_cuda/oomerge_define.cpp",
                        "merge_cuda/oomerge_driver.cu",
                    ],
                    extra_compile_args={
                        "cxx": ["-g"],
                        "nvcc": [
                            "-Xcompiler",
                            "-rdynamic",
                            "-lineinfo",
                            "-prec-sqrt=false",
                        ],
                    },
                )
            ],
            cmdclass={"build_ext": BuildExtension},
        )


if __name__ == "__main__":
    main(sys.argv)
