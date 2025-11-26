Notice all those packages under "links". Those should only be there when you build libtorch with "shared=false" - which
I didn't and don't want to do when building "shared" libraries to dynamically load from python.

The configuration option "shared" to the libtorch lua script (I think probably) collided with the built-in xmake flag
"shared" - which is used for any cpp project and defaults to false, (probably) overriding the special libtorch-custom
flag which was supposed to default to true.

Note also the ldflags that the xmake script created, which will probably work just fine, but somewhat differ from the
cmake flags (see cmake_flags.txt for the full cmake output):

```cmake
-Wl,-rpath,
/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib
/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libtorch.so
/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libkineto.a
/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libc10.so
/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libc10_cuda.so

-Wl,--no-as-needed,
/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libtorch.so
/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libtorch_cpu.so
/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libtorch_cuda.so

-Wl,--as-needed
/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libc10_cuda.so
/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libc10.so
```

I've tried to align the xmake flags to match the cmake ones above (see xmake_modded.txt)

---

Xmake original libtorch generated configuration for v2.6.0:

```jsonlines
{
  linkdirs = {
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib"
  },
  links = {
    "fbgemm",
    "pytorch_qnnpack",
    "protobuf",
    "onnx_proto",
    "XNNPACK",
    "pthreadpool",
    "cpuinfo",
    "fmt",
    "microkernels-prod",
    "kineto",
    "dnnl",
    "nnpack",
    "protoc",
    "protobuf-lite",
    "sleef",
    "asmjit",
    "onnx",
    "clog"
  },
  libfiles = {
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libfbgemm.a",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libpytorch_qnnpack.a",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libprotobuf.a",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libonnx_proto.a",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libXNNPACK.a",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libpthreadpool.a",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libcpuinfo.a",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libfmt.a",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libmicrokernels-prod.a",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libkineto.a",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libdnnl.a",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libnnpack.a",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libprotoc.a",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libprotobuf-lite.a",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libsleef.a",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libasmjit.a",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libonnx.a",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libclog.a",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libc10.so",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libtorch_cuda.so",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libtorch.so",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libcaffe2_nvrtc.so",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libc10_cuda.so",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libtorch_cpu.so",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libtorch_global_deps.so"
  },
  sysincludedirs = {
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/include",
    "/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/include/torch/csrc/api/include"
  },
  static = true,
  license = "BSD-3-Clause",
  shared = true,
  version = "v2.6.0",
  syslinks = "rt",
  ldflags = {
    "-Wl,-rpath,/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib",
    "-Wl,--no-as-needed,/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libtorch.so",
    "-Wl,--no-as-needed,/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libtorch_cpu.so",
    "-Wl,--no-as-needed,/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libtorch_cuda.so",
    "-Wl,--no-as-needed,/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libc10.so",
    "-Wl,--no-as-needed,/home/chris/.xmake/packages/l/libtorch/v2.6.0/069c90e8464e46bfb408aefca313237c/lib/libc10_cuda.so"
  }
}
```
