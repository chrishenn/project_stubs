# cpp

build cpp binary to c++26 standard with clang@21.1

- mise
  - provides pixi
  - sources the build env when entering project dir
  - provides tasks to trivially build, run project bin
- pixi installs the dev shell with
  - cmake@4.0.2 (matches latest built into IDE)
  - ninja
  - clang

- IDE
  - can source the same build env file
  - can trivially show assembly in editor for a built binary

```bash
# build manually
cmake -G Ninja -S . -B build
cmake --build build

# build with mise task
mise build

# run manually
./build/cpptest

# run with mise task
mise cpptest
```
