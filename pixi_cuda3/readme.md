# pixi_cuda3

build a single conda package with rattler build.

note: use pixi_cuda2 instead

---

The result is a jankier and broken version of the pixi_cuda2 scheme

there's no explicit package dep on the .so file,
so it won't be distributed with a package build for pixi_cuda3. but the pixi install command says it's patched the .
so and it's included in the package? not sure if this will work or not

I would need to get it to copy into the build dir but also
be findable from the editable (source tree) install, and I'm not sure how I would do that atm.

other problems:

- no caching for cpp builds
- no awareness of cpp files vs cmakelists.txt changes
- less flexibility, since the .so file will not copy into the source tree on build (not sure how to)

Even though the sources are technically in the same package, you still have to install the .so module into your
conda env, because I can't get the .so file to copy into source on build.

- Verified that the .so file is in the editable conda archive
- Verified that the .so file is in the built conda package
- it is NOT included when building a wheel with 'uv build'

Why is the python source not included? not sure this is building a valid package

```json
{
  "paths": [
    {
      "_path": "lib/python3.13/site-packages/csrc.cpython-313-x86_64-linux-gnu.so",
      "path_type": "hardlink",
      "file_mode": "binary",
      "prefix_placeholder": "/home/chris/Projects/project_stubs/pixi_cuda3/.pixi/build/work/pixi_cuda-YjXez8/ho...",
      "sha256": "blah",
      "size_in_bytes": 68640
    }
  ]
}
```

the mamba example adds a hardlink, possibly what we want
https://github.com/prefix-dev/rattler-build/blob/main/examples/mamba/build_mamba.sh

echo "Adding link to mamba into condabin";
mkdir -p $PREFIX/condabin
ln -s $PREFIX/bin/mamba $PREFIX/condabin/mamba

the mamba recipe builds with multiple "outputs", which is just multiple "packages" provided by the same codebase.
They also can provide a build script for each package

```yaml
outputs:
  - package:
    name: libmamba
    build:
      script:
        - ${{ "build_mamba.sh" if unix }}
        - ${{ "build_mamba.bat" if win }}
  - package:
    name: libmambapy
    requirements:
      host: ${{ pin_subpackage('libmamba', exact=True) }}
      run: ${{ pin_subpackage('libmamba', exact=True) }}
  - package:
    name: mamba
    build:
      python:
        entry_points:
          - mamba = mamba.mamba:main
    requirements:
      host:
        - ${{ pin_subpackage('libmambapy', exact=True) }}
      run:
        - ${{ pin_subpackage('libmambapy', exact=True) }}
```

creates a pin to another output in the recipe with an exact version.

ok so I've tried this, and it does work nicely with ratter-build

```bash
rattler-build build --recipe packages/pixi_cuda
```

my idea was that I'd include "csrc" as a build-time dep for "pixi_cuda", meaning it would build and be present when
the package for pixi_cuda was built. I was hoping that the Cmake for "csrc" could install the .so into the build dir
source folder for "pixi_cuda", meaning that the .so would be included in the wheel and/or sdist when built. Highly
convoluted and def not easy to understand at first glance.

I think it's pretty clear that building a full-fledged conda package for "csrc" and giving it a special name, and a
canonical pixi versioned dep for "pixi_cuda", is the best choice.

- I can't get the .so to be picked up by uv nor "python -m pip install" when building conda pkg
  I'll be they're diff pkgs with diff deps, so they're built in diff envs
- the pixi-build-rattler-build backend cannot invoke a rattler-build recipe in a way that I can see right now, where
  there are multiple packages in the recipe.yaml. The pixi.toml can only have one [package] table per file, and
  there needs to be a [package] table for each package name - one for "csrc", one for "pixi_cuda"

The mamba example manually hardlinks the "mamba" binary into "$PREFIX/condabin/mamba", which has got to be directly
in the .pixi conda env? Can't see that being great
