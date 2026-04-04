# python + cuda + bazel

Bazel is not into just building a binary and then installing it somewhere. Bazel makes it near-impossible
to use it as part of another builder or packaging process.

Possibly we could do something like

https://www.youtube.com/watch?v=ldn4RiyN25c

https://github.com/bazelbuild/rules_pkg/releases

Use a python script to invoke the bazel build, then package the output into a zip. Then print the output of that zip,
which you can use the python script to extract and move the compiled extension into the source tree.

Not quite ideal. I'd like to use the native uv-hatch build and package tools, and just build the cuda/cpp/pybind extension
with bazel.

Another qualm: CMake can find_package(python) and automatically find the installed torchlib that ships as part of the
installed pytorch package from pypi. It's automatically findable in the environment - not sure if bazel has the capability
to automatically find the installed torchlib (torch is built with bazel, after all) but I could not get the pytorch project
to show up as a bazel target with minimal faffing, so, ymmv

---

Update:

~~Bazel has native handling of downloading and unzipping archives as deps. So that's a big improvement over meson~~

Nevermind! It doesn't cache the damn archive, so you download like 2.5GB on each build. WTH?!
So now I have to manually download it once, and then comment out the archive and use new_local_repo after. What a joke

There is quite a bit of power and configurability in bazel. But, I have to already know what I'm doing re compiling
and linking my cuda, cpp, and pybind dependencies, because much of the linking appears to be handled manually.

This may be partly due to the fact that cuda support has just been added recently - whereas meson obviously prided itself
on configuring projects with many lanugages as first-class features.

Can't seem to detect the correct cudatoolkit from env. Have to hardcode the system path, or, use the hermetic cuda setup,
which is apparently what tensorflow does:
https://openxla.org/xla/hermetic_cuda
https://github.com/tensorflow/tensorflow/blob/master/third_party/gpus/cuda/hermetic/BUILD.tpl
this is like "full-time toolchain engineer" type stuff

I'm getting an undefined symbol on import. Is the cudatoolkit version mismatch with torch 12.4 the issue?
nvcc in shell is 12.4, but cudatoolkit at (hardcoded) /usr/local/cuda is 12.6.

Update:

The undefined symbol was due to missing the flag "-D_GLIBCXX_USE_CXX11_ABI=0", which borks the abi for the torch dependency -
if I'm remembering correctly, torch uses a glibc version with whichever version is (not?) CXX11_ABI. Meson and cmake both
find and mangle these flags automagically, which is REALLY NICE because the error is god-fucking-damn impossible to debug
otherwise.

I can't figure out how to invoke nvcc on my pybind (now nanobind) shared lib. Right now, it builds two objects, one .so
and one .lo, and they do import and run correctly. However, I can't figure out how to build these with static links to
deps so that they can be copy-pasted and moved. Right now they scream about not finding one of the torch .so's on import.
Trying to link these as static is throwing weird errors about them being linked against a dynamic version of libs under
glibc, and I can't get bazel to go get the static version. Why the fuck would a build tool link a dynamic version of glibc
when I'm building a static lib? Absolutely mental.

I have no doubt whatsoever that all of these issues can be resolved by writing the proper bazel code. However, the behavior
and reference is just MASSIVE and I would expect these very basic tasks to be handled sanely by default - and they're not.
