# pycu_msn

An example project to build a torch-cpp-cuda-python extension with this stack of tools:

- spack: system pkgs, shell env
- uv: python and python pkgs
- hatch: python packaging
- hatch-build-scripts: trigger extension build from hatch python dist build
- meson: generate build files to build torch-cpp-cuda-python extension

---

# Basic Commands

First time building the spack env:

```bash
source ~/spack/share/spack/setup-env.sh
spack -e . concretize
spack -e . install
```

Activate the spack environment, then the uv shell:

```bash
source ~/spack/share/spack/setup-env.sh
spack env activate . -p
source .venv/bin/activate
```

manually build the extension

```bash
pushd packages/pycu_msn
meson setup build
meson compile -C build
```

Trigger the extension build automatically as needed when src files change

```bash
uv sync
```

# Meson

Meson can use CMake to find most things, but for whatever reason it just flat-out refuses to find Torch. Even the local
copy I downloaded. If Meson worked as advertised, this would be no trouble at all. However: I ran into a handful of bugs
while trying to build this singular and VERY simple project (see the issues section below). As a result, I would approach
introducing Meson into any project with EXTREME CAUTION - though perhaps this particular set of requirements is just the
perfect storm that led to Meson pooping the bed.

I tried to use the meson-python backend at first, before I knew how difficult meson would be on its own, re Torch. That
just made debugging more difficult, and so I've switched to ol' reliable: hatch-build-scripts.

Like some of these other tools, you just have to download Libtorch pre-built and use it as a subproject from meson. There
theoretically should be an easy way to go looking in the python env for site-packages that can be used as deps, but Meson
is breaking in ways that make that impossibe.

---

# Issues

First and absolutely foremost, the Meson documentation is just absolutely crap. Even compared with Xmake's documentation,
which is written in somewhat poor english, Meson's docs are an endless headache. The CLI is next-to-useless, providing no
useful output on bugs; you have to manually open the log file to see detailed output, which is then overwritten on the next
invocation.

I can see comprehensive mounds of detail and nuance, clearly spelled out in the documentation. Yet the information is not
glanceable; I can never find what I'm looking for; the search is barely functional; the layout is simultaneously way too
dense and yet has very little information on the screen; it's just a huge pain to try to figure out how to do any simple
basic task. For simple examples:

- I want to find python libs that are in the active python env, and pass them to meson objects in the build file
- I want to modify env vars in the build file
- I want to download and unzip a zipped library of prebuilt binaries, when it's not present on disk

Perhaps there are simple ways of doing these things in meson, but I've spent for longer than I'd like to already, reading
the documentation, and these methods have not made themselves clear. If you're going to include a whole bunch of poorly-documented
magic, you need to have sufficient explanations BEYOND THE ABSOLUTE SIMPLEST CASE AND INCLUDING EXAMPLES OF THE
CORRECT SYNTAX!!!!!!

People who are less familiar with the "old" style of building their language compilation units should be able to glean the
relevant background information from your documentation! Because under the hood you're compiling all of the same object types!!

The design choice of disallowing globbing is irksome. I understand what they're going for, and, I don't care much for the
implementation.

Secondly but not the least, are the bugs. I will grant that pytorch is a huge, old, arcane, and ultimately difficult library
to deal with. That being said, there SHOULD be MANY ways to work around this - a select few of which are listed below.
These workarounds all fail because of bugs in meson's cmake invocation logic.

Setting these SHOULD allow cmake to find Torch

```cmake
list(APPEND CMAKE_MODULE_PATH /home/chris/Projects/pycu_msn/.venv/lib/python3.13/site-packages/torch/share/cmake)
list(APPEND CMAKE_PREFIX_PATH /home/chris/Projects/pycu_msn/.venv/lib/python3.13/site-packages/torch/share/cmake)
set(Torch_DIR /home/chris/Projects/pycu_msn/.venv/lib/python3.13/site-packages/torch/share/cmake/Torch)
list(APPEND CMAKE_PREFIX_PATH /home/chris/Projects/pycu_msn/.venv/lib/python3.13/site-packages/)
```

Cmake fails in some nvcccudacheckcompiler.cmake file because a path in not properly escaped

```bash
meson setup build --cmake-prefix-path $(python -c 'import torch.utils; print(torch.utils.cmake_prefix_path)')
meson setup build --cmake-prefix-path $(python -c 'import site; print(site.getsitepackages()[0])')
```

Here meson appears to just completely fail to modify the cmake module path

```meson
libtorch_dep = dependency('Torch', cmake_module_path: '/home/chris/Projects/pycu_msn/.venv/lib/python3.13/site-packages/torch/share/cmake')
```
