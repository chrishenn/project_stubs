# simple_mypyc

An example repo to demonstrate a simple project that compiles using mypyc.

The stack is roughly:

- uv: python and python pkgs
- hatch: build python dist {wheel, sdist}
- hatch-mypyc: hooked from hatch dist build to invoke mypyc compiler
- mypyc: compile mypy-compliant python code into native cython

Mypyc's greatest strength is that it is quite flexible in what it will transpile to native cython, and what will remain
native python, with excellent interoperability.

This means that python code that is very difficult to type with c-level primitives (think higher-order functions) can be
compiled by mypyc, with some theoretically small speedup in some cases.

This does present a double-edged sword, however; compiled code that is not easy to optimize for faster,
deterministically-behaving static-types may become SLOWER after compilation than the native python version. Mypyc seems
to excel with basic statically-typed functionality provided by mypy, while interoperating (usually!) well with more
esoteric python using modern typing annotations.

---

To trigger the build hook and install the python package as editable, simply run

```bash
uv sync
```

To build the python package for distribution, you would run

```bash
uv build --package pymypyc

# or, equivalently:
uv build --all
```

run the basic test with

```bash
pytest
```
