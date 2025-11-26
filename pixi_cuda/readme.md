# pixi_cuda

built with a top-level src and subpackages layout

note: use pixi_cuda2 instead

---

Cmake Strategies:

1. You can use the default CMake install() command to install the built .so as if it were a python module - which it
   usually would be, if built with nanobind. It just so happens that our TORCH_LIBRARY is not an importable module.
   It is installed as a conda package in the env, though - so you can use importlib.util.find_spec(<name>).origin to
   find the path of the .so, which you can then import into torch.ops as usual.

2. If you use the CMake install command to install the built .so into the source tree, then you will have the .so file
   in the source tree as desired. But, the package "csrc" you've declared will show up in the conda env and have no
   files installed for it in site-packages.

Either way, the pixi-build-python backend will install the src code in "editable" mode, so that you're running the
python source directly from the source tree (project files). This means that I can set a breakpoint inside
pixi_cuda/**init**.py for debugging, and it will still find the .so file from the "csrc" package.

The "pixi-build-cmake" backend will rebuild the extension when a .cpp file or the CMakeLists.txt in "csrc" are
changed - even whitespace - but not a .cu file. I think that can be manually added to some "source" key in the
pixi.toml.

edit: yes I was right. source files are hardcoded in the build backend as:
// Source files
"**/\*.{c,cc,cxx,cpp,h,hpp,hxx}",
// CMake files
"**/\*.{cmake,cmake.in}",
"\*\*/CMakeFiles.txt",

Every rebuild after a .cpp file changes appears fresh - but I think that's because the cuda objects have to be
rebuilt. If the CmakeLists.txt file changes in a trivial way, the build is warm - not fresh.
