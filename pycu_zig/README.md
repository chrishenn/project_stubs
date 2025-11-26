# pycu_zig

## Step 1: build cuda kernels and torch cpp with zig

currently working on adding cpp/cu and external deps, using
https://github.com/akhildevelops/cudaz

settled on zig 0.13.0, since cudaz supports it, then manually updating the pydust code to use it, even though pydust
was written on 0.11.0

## Step 2: build a python module with those extensions inside that can be imported and run from python

problem: because pydust depends on ziglang@0.11.0, it installs the pip package ziglang@0.11.0 and invokes it with its
python build script. So you can put zig@0.13.0 in the shell, it won't matter.

We should choose a zig version, then either
a) put it in the shell env and re-implement all the pydust functionality manually, or
b) use the ziglang package installed into the python env

```bash
# see the version of zig that's bundled into the python pip package
python -m ziglang version

# the build comamnd invoked by pydust's build script
python -m ziglang build --build-file build.zig install -Dpython-exe=/path/to/python -Doptimize=ReleaseSafe
```

---

ref
https://zig.news/xq/zig-build-explained-part-3-1ima

linking cuda kernels as c headers?
https://github.com/pjreddie/darknet

linking cuda to zig
https://ziggit.dev/t/advice-on-linking-cuda-to-zig/2405/36

https://github.com/andrewCodeDev/Metaphor/
https://ziggit.dev/t/metaphor-gpu-machine-learning-library-for-zig/3317

https://github.com/Marco-Christiani/zigrad

https://github.com/gwenzek/cudaz
https://github.com/akhildevelops/cudaz

---

# Hacks

Spack no longer sets LD_LIBRARY_PATH becuase spack binaries don't need to read it from the env, and system bins will
see LD_LIBRARY_PATH, find spack libs, and break.

This is the one-time workaround to change spack's behavior to set LD_LIBRARY_PATH in the activated env:

```bash
spack config add modules:prefix_inspections:lib64:[LD_LIBRARY_PATH]
spack config add modules:prefix_inspections:lib:[LD_LIBRARY_PATH]

# verify that path is set to ...view/lib64
echo $LD_LIBRARY_PATH
```

But the fundamental problem is that zig's invocation of libnvrtc.so goes looking for libnvrtc-builtins.so using
LD_LIBRARY_PATH. Not sure what the fix is here (RPATH?) but this relies on a system installation of the cudatoolkit
and is not ideal.

We also need to hardcode the cudatoolkit path into the zig build command, even though CUDA_HOME is clearly set. This
is a somewhat primitive limitation of cudaz

One-time fetch of cudaz zig dep.
Automatically populates the has into the project's buid.zig.zon

```bash
# this tarball was build against zig 0.14.0
zig fetch --save https://github.com/akhildevelops/cudaz/archive/0.2.0.tar.gz
```

Build main program and install to zig-out, and optionally execute it by calling the zig "run" step

```bash
cd packages/pycu_zig/csrc
zig build
zig build run
```

# Commands

activate the dev env

```bash
. env.sh
```

---

# Notes

There is no package right now (mise, spack) with a zig binary tracking the master branch. The lang is changing super
fast right now, so it's worth the headache to install and version the latest master manually

update: nvm. Make sense to install 0.13.0 and update the pydust build logic to match

    Pydust: 0.11.0
    cudaz:  0.13.0, 0.14.0
    pip:    0.13.0

---

pytest tries to hook the ziggy-pydust builder, and it runs from the wrong directory, so it can't find the package
pyproject.toml.

solution: added -p no:pydust to the root pyproject.pytest_ini table

much clumsier solution, to disable all plugin autoloads:

```bash
PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 pytest
```
