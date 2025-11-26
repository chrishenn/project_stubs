# pycu_nb

An example project to build a torch-cpp-cuda-python extension with this stack of tools:

- spack: system pkgs, shell env
- uv: python and python pkgs
- hatch: python packaging
- hatch-build-scripts: trigger extension build from hatch python dist build
- meson: generate build files to build torch-cpp-cuda-python extension
- nanobind: provide a python/cpp interface api with ndarray support for numpy+pytorch+jax

nanobind supports ndarrays from all these providers simultaneously:

- numpy
- pytorch
- tensorflow
- jax
- cupy

You will need to manually manage the memory as passed between python and cpp. Thankfully, nanobind includes some
neat and modern "policies" and destructor-callbacks that will make this much less painful than manual refcounting
from the old cython days. Very cool!

I'm not 100% sure about the free-threaded and no-gil situation, but the documentation is already 100x better than
most of these build-tool projects I've been exploring lately.

Sans the pytorch dependency, meson handles this use case like an absolute champ. There's custom logic and a recipe
to use nanobind with meson already. Incredible!

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

alternatively:

```bash
source env.sh
```

Meson can't find the python-installed nanobind package.
No matter, there's a pre-baked solution to build the nanobind dep:

```bash
mkdir -p subprojects
meson wrap install robin-map
meson wrap install nanobind
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

---

## jetbrains workarounds

launch clion from a shell with the env already active, so that automatic builds work. So:

```bash
cd pycu_nb
source env.sh
# you have to open the folder with the meson.build file inside it, otherwise jetbrains can't find the meson project
clion ./packages/pycu_nb
```

create "compilation database project":

```bash
pushd packages/pycu_msn
meson setup build
pushd build
ninja -t compdb > compile_commands.json
```

jetbrains -> file -> open -> compile_commands.json -> "open as project"

and you get code insight even on cuda code! Amazing

---

## uv bugfix

sometimes uv sync will correctly build and sync the project, and uv pip list will show it as installed, but
then python can't import it. Try

```bash
uv init --package packages/pycu_nb
```

which appears to correct the issue. I think there's some oddity with package name `pycu-nb` but python import name
`pycu_nb`, where the env activation hook fails to register correctly in the uv .venv by default when you define the package
just using the pyproject.toml file.

From the astral docs:
By default, running uv init inside an existing package will add the newly created member to the workspace, creating a
tool.uv.workspace table in the workspace root if it doesn't already exist.

---
