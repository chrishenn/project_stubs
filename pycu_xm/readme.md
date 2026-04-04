# python + cuda + xmake

An example project to build a torch-cpp-cuda-python extension with this stack of tools:

- spack: system pkgs, shell env
- uv: python and python pkgs
- hatch: python packaging
- hatch-build-scripts: trigger extension build from hatch python dist build
- xmake: generate build files to build torch-cpp-cuda-python extension

---

# System Package/Environment Management

Xmake and devbox don't mix. Xmake will search in various places, using various system bins, to find a dep package. It
fails to find most things when inside devbox. I would assume that any nix-based shell manager would result in xmake's
logic failing. Including failing to find the system cuda gpu.

I've managed to acheive some success using xmake inside of spack.

You'll have to bring a system install of uv, xmake, and spack, but wow! It's a joy when it all works together.

---

# Basic Commands

Activate the spack environment, then the uv shell:

```bash
source ~/spack/share/spack/setup-env.sh
spack -e . concretize
spack -e . install
spack env activate . -p
source .venv/bin/activate
```

Manually configure and build the xmake project:

```bash
pushd packages/pycu_xm/pycu_xm
xmake f -p linux -a x86_64 -m release -vD -c
xmake -y
```

Automatically build the extension (invoking xmake from hatch-build-scripts):

```bash
uv sync
```

---

# XMake

Local copy of libtorch is kinda crappy, and is a manual process. If you know lua, I'll bet you could write a lua script
to download and extract the libtorch zip archive, in the same vein as meson has a python script to do that.

Devbox and spack cannot coexist
Devbox and xmake/xrepo may be clashing in their env management. Not sure

I activated the spack env and xmake still found the cudatoolkit at /usr/local/cuda. NOPE THATS NOT GOOD
xmake found spack env locations for cmake, gcc
xmake found system locations for git, gzip, tar, ping, dpkg, pkg-config, ld, libffi-dev, zlib, openssl, ca-certificates

wait how is it finding ld on the system but gcc in spack?
when xmake ran the torch cmake, torch's cmake detected the spack env cudatoolkit. huh??
running "which nvcc" gives the spack nvcc. uh oh!

ok! I renamed the system install of cudatoolkit and now xmake has found the spack cudatoolkit. that's not the best, but
pretty good.

---

# Building Libtorch

## Method 1: Download the Prebuilt Library

This is probably the preferred method; this lib takes a damn long time to build.
Make sure that the main build script under packages/mypkg/xmake-project/xmake.lua points to xmake-project/ext/libtorch
for this add_requires.

It's also crucial that you download a compatible version of libtorch for your python package's build of torch that it uses
internally.

```bash
wget https://download.pytorch.org/libtorch/cu126/libtorch-cxx11-abi-shared-with-deps-2.6.0%2Bcu126.zip -O torch.zip
unzip torch.zip -d packages/pycu_xm/pycu_xm/ext
```

```lua
add_requires("cmake::Torch", {alias = "libtorch", configs = {envs = {Torch_DIR = path.absolute("ext/libtorch")}}})
```

## Method 2: Build from Source

The xmake.lua script under repo/l/libtorch/xmake.lua basiclaly checks out the pytorch src tree and invokes cmake to build
the project.
Theoretically you could pass flags for your target architecture(s) to build this with specific optimizations.
Note that it takes like ~20 minutes to build on a modern cpu, for a single cuda gpu arch.

```lua
add_repositories("localrepo repo")
add_requires("libtorch", {configs = {cmshared=true, cuda=true}})
```

---

# Torch Compatibility Recipe

https://github.com/pytorch/pytorch/blob/main/RELEASE.md#release-compatibility-matrix

Download libtorch manually from https://pytorch.org/get-started/locally/
torch: 2.6.0
cuda: 12.6
cudnn: 9.5.1.17
c++: 17
python: <=3.13 (3.13t experimental)
rocm: 6.2.4
cxx11abi: yes

I believe CUDA also provides hard version caps in their custom cmake logic:
cuda: 12.4
gcc <= 13
clang <= 17

Torch built their python wheels with CXX11_ABI=0 as of torch 2.5.1, but the wheel for torch 2.6.0+cu126 they
set CXX11_ABI=1.
You can download any version of libtorch with regards to the cxx11_abi, but crucially you MUST build the extension with
the same setting.

This flag (D_GLIBCXX_USE_CXX11_ABI) defaults to "true" under xmake, so it's only necessary to set when you want to build
with it off:

```lua
add_cxxflags("-D_GLIBCXX_USE_CXX11_ABI=0")
add_cuflags("-D_GLIBCXX_USE_CXX11_ABI=0")
```

---

# Debugging Commands

Comment out the problematic add_requires() packages in your xmake.lua. Then, use xrepo env shell to activate the xrepo env.
Activating the xrepo env using that xmake.lua file will attempt to build/install those packages using the configs you've
specified in the xmake.lua file.

xmake/xrepo will attempt to build a shell in which the xmake::libtorch and xmake::cuda-12 have be built and installed,
using my toolchain configuration.

```bash
xrepo env shell
```

manually build the libtorch dep from local repo

```bash
pushd packages/pycu_xm/pycu_xm
xmake repo --add myrepo repo/
xmake install libtorch@2.6.0
xmake require --info libtorch
```

list installed packages, search for info

```bash
xmake require --list
xrepo search cuda
xrepo info cuda
```

install, uninstall

```bash
curl -fsSL https://xmake.io/shget.text | bash
source ~/.xmake/profile

xmake require --uninstall xmake
```

uninstall

```bash
xmake require --uninstall --extra="{configs={cuda=true}}" libtorch
xmake require --uninstall --extra="{configs={cuda=true, cmshared=true}}" libtorch
xmake require --uninstall --extra="{configs={cuda=true, shared=false}}" libtorch
```
