# pycu_ref

An example repo to demonstrate a working stack of tools to build a python package that includes a torch-cpp-cuda extension.

This repo explores environment-management tools:

- nix (flake.nix)
- flox
- devbox
- spack
- singularity
- modulefiles (lmod)
- scikit-build-core

---

As of today, the working stack(s) in this repo include(s):

- (see below): system pkgs, shell env
- uv: python and python pkgs
- hatch: python packaging
- hatch-build-scripts: trigger extension build from hatch python dist build
- cmake: generate build files to build torch-cuda-python extension
- (nanobind:) include bindings for cpp-to-python, but is overridden(?) by pytorch's bespoke pybind11 machinery

There are four interchangeable environment (shell + build dep) package managers:

- nix (flake.nix)
- flox
- devbox
- spack

The only one that is truly lacking basic features that we want is the nix flake, alas. You cannot easily pin package versions
for nixpkgs that are being assembled into your dev shell.

Other than that, flox and devbox have some minor quirks, but are more or less equivalently good at doing what we want.

Note: It would be REALLY REALLY NICE to be able to get rid of cmake altogether. As the de-facto standard, though, there
simply is no competitor on features. I just hate hate HATE the syntax and terrible scoping rules, which I'm sure a much
cleverer man would just modernize with more explicit language conventions like we're used to.

Note: For whatever reason, these solutions all install ancient (like 4 months old, not so bad in the grand scheme) versions
of uv. It's not entirely clear why, but I don't think it poses any immediate problems.

Note: Another quirk specific to both flox and flake.nix, I could not get the extension to build with python 3.13, despite
every single tool telling me that python 3.13 was the only one it could find. Hand to god, it would build the ext with
cpython-312 in the name every single time, and I have no idea how or why. The devbox env builds against python 3.13 correctly,
so they must have sprinkled in some extra sauce ... or it's just some quirk of luck.

---

# Build Env Packages

Just for reference, this project requires roughly these "system" or "environment" or "shell" packages in order to build
from source. I'm using mise for this:

- gcc-13
- cudatoolkit-12.4
  or
- gcc-15
- cudatoolkit-13.0

- uv
- cmake
- ninja

Then the python packages required, roughly:

build backend

- nanobind
  or
- pybind11
- hatch-build-scripts
- torch

dev deps

- pytest
- ruff

runtime deps

- numpy
- torch

Both pybind11 and nanobind are interchangeable, and I think also totally redundant. I believe that torch ships with
all the pybind11 machinery needed to create python bindings, and the settings I give to cmake's pybind11/nanobind interface
appear to be ignored.

See CMakeLists_ref.txt for the syntax to invoke "traditional" python extension, allowing torch's pybind stuff to
handle binding.

hatch-build-scripts is easily interchangeable with scikit-build-core. However, there is not much benefit to scikit-build-core
over a simple hatch-build-scripts command that invokes cmake, at this point. It seems like much of the functionality of
scikit-build-core has been added to cmake's native find_package(Python) behavior, at least for the purposes of what I'm
up to in this example project.

Note on cmake:
dirty builds are throwing
"ninja: error: '/home/chris/.cache/uv/builds-v0/.tmppzJfWZ/lib/python3.13/site-packages/torch/lib/libc10.so',
needed by '\_C.cpython-313-x86_64-linux-gnu.so', missing and no known rule to make it"
I have no idea why. I've just made hatch-build-scripts build clean every time for now

---

# System Package/Environment Management

## Interactions

A note on combining these tools: your mileage may vary. They all hack your current shell to include various env vars, pointing
to various places (the nix-based shells point to the /nix/store, while spack installs packages under $HOME). I've only tested
using bash under linux, but they are generally not designed to be used together, so who knows what wacky interactions you
might encounter.

Spack and Devbox appear to super duper break each other's env, and it is
extraordinarily difficult to try unfuck devbox once it's hooking busted spack init bash. Where tf does it store that state?
I had to nuke all the nix/store\*devbox mentions manually each time.

## Nix Flake

A devshell created by the flake.nix does work. The way to pin versions for input packages is not clear.
The nix syntax leaves much to be desired, for me, at the moment. That could be a personal and/or temporary limitation.

To set up the work env, run:

```bash
# this command assumes you installed nix using the determinate installer
nix develop
source .venv/bin/activate

# if you did not use the determinate installer, rather, say, the flox installer, then
nix develop --extra-experimental-features nix-command --extra-experimental-features flakes
source .venv/bin/activate
```

## Devbox Shell

Nice, declarative syntax using plain json. I definitely had problems with the out-of-the-box python integrations, given
the other complications with cpp-torch-cuda dependencies in this project. Likely it would be less of an issue for a more
straightforward python or rust or go or node project.

```bash
# uv commands will work correctly using just the devbox shell, exposing the uv binary to us
devbox shell
uv sync

# but commands like "pytest" will require the uv env to be active in order to find uv-managed python packages
source .venv/bin/activate
pytest
```

## Flox

Works slightly differently than both nix and devbox. The toml manifest format feels a but less clean. More importantly,
their environment solver attempts to merge each and every file from each package into a shared ... structure of some kind.
Which means that packages like cudatoolkit and cudnn will "conflict" with each other, simply because they each have a
"LICENSE" file that wants to go into the same place in the merged system. Conveniently, there are two mechanisms to manually
decide on tiebreakers (package-groups, and priority integers). You can specify an integer (1-5) for each pkg that will decide
which package's conflicting files take precedence. Simple, and granular, but also requires some extra manual fiddling when
putting together an env.

However! The killer feature in flox (right this moment) is the ready-made shell script that will redirect your uv environment
into a place inside the .flox/ directory. This neatly encapsulates all system deps (nixpkgs) in addition to a WORKING
uv virtual environment in a single place!

I'm very sure that devbox users would like this integration to work as well, but, well, here we are.
When first initializing the environment, I did use the interactive prompt to say "yes make a python plugin with a venv for
me" but I'm not totally sure that was necessary. If you look at the manifest file under .flox/env/manifest.toml, you'll
see that the shell activation hook manually munges a bunch of UV environment variables to make uv work. I stole that
shell script from the excellent flox examples repo https://github.com/flox/floxenvs.

Note: I could not install python using flox and also get the flox env to work correctly.

```bash
flox activate
pytest
```

## Spack

Spack is the one env-pkg solution here that is NOT based on nixpkgs.

Spack worked well to make system-level packages available in an isolated shell. One drawback here was
trialing different cuda/gcc/clang combos to find a working recipe - building gcc and/or clang from scratch, for each version,
is damn slow. On the other hand, that could be a huge advantage depending on what you're up to (HPC would probably prefer
to build for source, enabling hardware optimizations for the target machine).

Another drawback is the documentation and cli. Similar to the nix ecosystem, the documentation is way too flowery and
diffuse (though not as bad as nix), and the cli design is unnecessarily cluttered.

Nixpkgs (famously) has a much wider range of packages available. However, spack's packages offer (for example) a newer
version of the cudatoolkit than nixpkgs does, precisely because they specialize in providing software dependencies for
building HPC applications. Which is basically what this example python/torch/cuda/cpp library is, at its core.

When you specify to spack

```yaml
modules:
  prefix_inspections:
    lib: [LD_LIBRARY_PATH]
    lib64: [LD_LIBRARY_PATH]
```

What this does is create a file under /etc/ld.so.conf.d/ for each package. In our case, we have a manual
installation of the cuda toolkit;

```bash
# /etc/ld.so.conf.d/cuda-13-0.conf
/home/chris/cuda/cuda-13.0/targets/x86_64-linux/lib
```

presumably this path will be appended to LD_LIBRARY_PATH when spack loads these packages into the active env.

Note: gcc@14 is indeed incompatible with cudatoolkit 12.4/12.6/12.8

Note: spack and devshell absolutely do not get along. Not sure why, just be sure to avoid using both in the same
shell.

Note: cuda spack installation issue. spack just calls the nvidia driver runfile to intall the toolkit, but the runfile
fails unless invoked as root. So I had to download and install it manually to my local folder, then add it as an
"external" package in spack, using packages.yaml
Spack has a cudnn package, but we're using a manual install for cuda13 so that won't work right now

Note: got the project to build with spack's clang install. However, couldn't get llvm+cuda to install from spack.
The clang package from mise builds in a fraction of the time, probably(?) since it doesn't build as many deps.

- llvm@20.1.8 +clang

install spack user-wide

```bash
git clone --depth=2 --branch=releases/v0.23 https://github.com/spack/spack.git ~/spack
```

activate the build env

```bash
source ~/spack/share/spack/setup-env.sh
spack -e . concretize
spack -e . install
spack env activate . -p
source .venv/bin/activate
```

create a new build env

```bash
spack env create -d .
spack install --add cuda@12.6 gcc@13.3 cmake@latest ninja@latest
```

see available package versions

```bash
spack versions gcc
spack versions cuda
```

deactivate spack env

```bash
despacktivate
spack env deactivate
```

spack bugfix
https://github.com/spack/spack/issues/17652
workaround: install perl manually

```bash
spack install -v perl@5.42.0
> there's an interactive prompt to continue the install
```

---

# Commands

To trigger the build hook and install the python package as editable, make a code change and run:

```bash
uv sync
```

To build the python package for distribution, you would run:

```bash
uv build --package pycu_ref
```

run the basic test with:

```bash
pytest
```

cmake debugging

```bash
cmake --debug-output -G Ninja -S . -B build
cmake --trace -G Ninja -S . -B build
```

---

# Experiments that didn't work

## Clang

Note about the below: not sure what happened here. Cmake finds libstdc just fine with spack/mise.

If you install clang, then cmake can't find libstdc++.so in the shell env!!!!
you can install libstdcxxClang, but good luck getting cmake to pass the correct flags to the correct compilers at the right
time!!!

```bash
touch empty.cu
clang++ empty.cu --cuda-gpu-arch=sm_86 -stdlib=libstdc++ -c
clang++ empty.cu --offload-arch=sm_86 -stdlib=libstdc++ -c
clang++ -c empty.cu --cuda-gpu-arch=sm_86 --cuda-path=$CUDA_HOME

clang++ --std=c++17 -c empty.cu --cuda-path=$CUDA_HOME --cuda-gpu-arch=sm_86

```

```toml
[install]
cmake.pkg-path = "cmake"
ninja.pkg-path = "ninja"
uv.pkg-path = "uv"

# could not get mold to find libstdc++ when running pytorch's native cmake modules
mold.pkg-path = "mold"

gcc.pkg-path = "gcc"
gcc.version = "13"

#gcc_unwrapped.pkg-path = "gcc-unwrapped"
#gcc_unwrapped.version = "13"
#gcc_unwrapped.priority = 4

#clang.pkg-path = "clang"
#clang.version = "17.0.6"
#clang.pkg-group = "clang"
#clang.priority = 4

#libstd.pkg-path = "llvmPackages.libstdcxxClang"
#libstd.version = "17.0.6"
#libstd.pkg-group = "clang"

cudatoolkit.pkg-path = "cudaPackages.cudatoolkit"
cudatoolkit.version = "12.4"

nccl.pkg-path = "cudaPackages.nccl"

cudart.pkg-path = "cudaPackages.cuda_cudart"
cudart.priority = 4

cudnn.pkg-path = "cudaPackages.cudnn"
cudnn.priority = 3


[options]
systems = [
  "aarch64-linux",
  "x86_64-linux",
]
# cuda-detection = false
allow.unfree = true
```

```cmake
# you can build cuda code from top-to-bottom with clang. I haven't gotten it to work with the compilation flags needed.
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)

# this is done automatically by sk_build; only needed when scikit_build is not used
# also not needed anymore, since find_package(Python) provides these for us in "result" variables.
execute_process(
  COMMAND ${Python_EXECUTABLE} -c "import site; print(site.getsitepackages()[0])"
  OUTPUT_VARIABLE py_site_packages OUTPUT_STRIP_TRAILING_WHITESPACE
)
```

---

## Scikit-build-core

deprecated older build backend scikit-build-core.
