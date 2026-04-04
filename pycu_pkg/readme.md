# pycu_pkg

formerly cuneb-chenn

Outdated example to build and ship a cuda-python torch extension

---

<h1 align="center" style="margin-top: 0px;">Example Pytorch-CUDA-CMake Library Pip-Package</h1>

&emsp;

An example pip-package for a CUDA/C++ Pytorch/Torchlib extension. Allows installing via pip, and importing to Pytorch or Torchscript. We can therefore specify package versions; install python dependencies automatically; and build the
package from source on a target machine.

The benefits of compiling a python model into torchscript are many - see the tutorial for a nice list [(extending torchscript tutorial)](https://pytorch.org/tutorials/advanced/torch_script_custom_ops.html) - but my main interest is in the
performance and scalability offered by serializing a model to disk (which can be loaded into multiple processes), and running a model in a python-free environment.

If our model makes use of custom CUDA/C++ projects, it can be tedious and manual work to compile and import them - not to mention keeping track of versions and subversions.

We choose CMake compilation for our CUDA/C++ library, rather than setuptools. CMake allows for fewer headaches in the extension's project structure - finding includes, headers, and source files is easier - and is generally worth the effort
of including another build tool. As the [extending torchscript tutorial](https://pytorch.org/tutorials/advanced/torch_script_custom_ops.html) casually mentions, using setuptools to build a plain shared library can be "slightly quirky". For
more complex projects, I've found this to be a charming understatement.

CMake functionality in setup.py adapted from [raydouglass/cmake_setuptools](https://github.com/raydouglass/cmake_setuptools).

## Using This Example

Installing the package from source, at install time we must specify the path to our appropriate version of the libtorch library on our machine's filesystem. This example includes dependencies on libtorch-1.8.2, pytorch-1.8.2, cuda-11,
cudnn-8.xxx, and gcc~9.

Make sure to set your Torch_DIR in your environment, specifying your local libtorch folder (here, with version 1.8.2). For example, in ~/.bashrc:

    export Torch_DIR="/home/chris/Documents/libtorch"

Otherwise, we can prefix each command below with Torch_DIR="path-to-libtorch".

To install the package from a local folder, open a shell in the package folder; run:

    pip install .

To call the extension from an environment with this package installed, we can then:

    import modulename
    output = modulename.get(*args)

To run the included tests from a local folder, we can do:

    pip install -e .
    nosetests

To build a package distribution, including a source and a system-specific wheel, run:

    python -m build

Wheels with 'linux-arch' tags cannot be uploaded to pypa - see 'Manylinux' section below.

If we remove the linux-tagged .whl from the pkg/dist/, we can then upload the package to pypi. Only installation from source will be supported, via the package-version.tar.gz file built by 'build'. Pip will download and unzip the package,
enforce dependencies, provide versioning, and install from source.

Alternatively, we can build only the 'source' distribution:

    python setup.py sdist

To upload the dist/ directory, set `token=our-secret-pypi-api-token` in our shell environment. Then:

    twine upload --skip-existing --verbose -p $token -u __token__ --repository "cuneb-chenn" --repository-url https://upload.pypi.org/legacy/ dist/*

Then to install in a fresh environment, pip will download the package source from pypi and build a local wheel to install:

    pip install cuneb-chenn

## Adapting This Example

File structure:

    pkg
    |-  setup.py
    |-  src
    |   |-  module
    |   |   |-   .env
    |   |   |-   __init__.py
    |   |   |-   CMakeLists.txt
    |   |   |-   file.cpp
    |   |   |-   file.h
    |   |   |-   file.cu
    |   |   |-   file.cuh
    |-  test
    |   |-  test_module.py

In the module/.env file, there are environment variable definitions (PKG_NAME MOD_NAME MOD_PATH OPS_NAME). PKG_NAME, MOD_NAME, and MOD_PATH correspond to package folder name, module folder name, and path to the module folder from setup.py.
OPS_NAME defines the torch.ops.OPS_NAME that the extension must be bound to. Setup.py will use python-dotenv to load these variables into the system environment at build time. Then, the installed module will reference them in the same way
to find its own \*.so file.

    ".env":

    PKG_NAME=cuneb-chenn
    MOD_NAME=cuneb
    MOD_PATH=src/cuneb/
    OPS_NAME=cuneb_ops

There are two additional places where these environment vars must be hardcoded: one at the top of setup.py, and one in pkg/module/module.cpp. These module names must agree with those in the .env file.

## ManyLinux

Wheels built on manylinux images and repaired with wheel-repair can then be uploaded to pypi. However, manylinux wheels for this package are much too large to upload because of its dependencies (seemingly CUDA-11 is the main offender here).

Run `sudo sh run-manylinux.sh` to start building manylinux wheels.

`run-manylinux.sh` specifies a manylinux docker container inside which the manylinux wheels are built (and tested - todo). You'll need docker installed. I've found manylinux containers built with CUDA
installed [(ameli/manylinux-cuda)](https://github.com/ameli/manylinux-cuda) which is very helpful, because the build is cantankerous and slow. However, it would be nice to build a version with an appropriate cudnn installed (todo).

`build-wheels.sh` is run inside the container to build and format the wheels.

### Notes

Use a machine with more than 64 GB of ram (maybe more like 256 GB) - push this to the build server (super easy CI integration with travis - see [the manylinux github tutorial](https://github.com/pypa/python-manylinux-demo) for info). I
copied a starting point for the two manylinux shell scripts from the same.

The wheel-size problem appears to crop up frequently. Pypa folks specifically call out Cuda-11 (and later) dependencies as inflating the .whl
size [(see here)](https://discuss.python.org/t/what-to-do-about-gpus-and-the-built-distributions-that-support-them/7125). As mentioned in that discussion, Pytorch has had to host and distribute their own python packages because the
infrastructure to store and deliver them is too expensive for Pypa.

This packaging exercise is still worthwhile for learning about CI. In particular, the cpu and memory requirements are quite high - just to build this simple little package! Suitable for an internal build and distribution server only.

## TODO

- TODO: add tests
- TODO: --use-feature=in-tree-build (will be default behavior in future. See if it breaks the package build)

- TODO: build-wheels.sh ends with an EOF error, but runs successfully to completion. Would be nice to finish with a success message rather than an error.
- TODO: local cudnn install in build-wheel.sh
- TODO: figure out what those -pypy-something binaries are in build-wheels.h
- TODO: build docker manylinux images with latest manylinux version, cuda, and cudnn built in
