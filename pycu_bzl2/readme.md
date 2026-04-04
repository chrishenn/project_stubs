# python + cuda + bazel 2

another crack at it
couldn't get it to build, even cpu-only. wah-wah

refs
https://gokulkrishna98.github.io/posts/torchscript-bazel/
https://discuss.pytorch.org/t/pytorch-and-bazel/42592/7
https://rules-python.readthedocs.io/en/latest/howto/python-headers.html

this may be worth looking into. this shit sucks
https://github.com/uber/hermetic_cc_toolchain

```bash
curl -LO https://download.pytorch.org/libtorch/cu129/libtorch-shared-with-deps-2.8.0%2Bcu129.zip

sha256sum libtorch-shared-with-deps-2.8.0%2Bcu129.zip
f6e85271c8594f740705517f2315ef358cd0d9347d7c92e2da51dcb1850fc763

pixi run bazel build :main --repo_contents_cache=/home/chris/Projects/project_stubs/bazel-cache --sandbox_debug
```
