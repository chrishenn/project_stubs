# python

A minimal python test project with uv, cuda, and environment tooling.

## Commands

```bash
# make sure mise is active in your current shell.
# Manually, for bash:
eval "$(~/.local/bin/mise activate bash)"

# or, automatically:
echo 'eval "$(~/.local/bin/mise activate bash)"' | tee -a ~/.bashrc
. ~/.bashrc

# install mise tools requested by the project's mise.toml
mise trust
mise install

# build and install the spack env
> just spack_build
    spack -e . concretize --fresh --force
    spack -e . install

# when active, mise will run a hook on entry to project dir to: activate uv venv, source spack from home install,
# activate spack env from ./spack.yml, and sync the uv venv (builds projects extensions if necessary)
# manually, that would be:
uv venv --allow-existing \
&& source .venv/bin/activate \
&& source ~/spack/share/spack/setup-env.sh \
&& spack env activate . -p \
&& uv sync

# just recipes
> just -l
Available recipes:
    lint          # lint and format [alias: l]
    lintpy        # python linters
    spack_rebuild # re-concretize+reinstall the spack env. After, you may need to reload the spack env with: `. spack_reload.sh`

# eg
> just lint
    uv run ruff format
    uv run ruff check --fix
    uv run mypy
    just --fmt --unstable
    mise fmt
    prettier . --write

# uv: build project python venv
uv sync
```

## Tools & Environment

### mise

- cmake@latest
- just@latest
- ninja@latest
- prettier@next
- uv@latest

shell hook, runs on entry to project dir:

- activate uv venv
- activate spack from standard home install location
- activate spack env defined in ./spack.yml

### spack

- cudatoolkit@13.0
- gcc@15

spack points to my local install of cudatoolkit@13.0 right now, as the spack package for 13.0 hasn't been released yet

### uv

- mypy
- pytest
- ruff

## Future

Right now, running the commands in the `just lint` recipe using gnu parallel makes the command run slower than
serial, due to their individual light weight and process overhead. However, heavier project tasks could potentially
run faster when parallelized with gnu parallel.

Another option to consider: the mise task runner has some sophisticated declarative syntax to specify a task build
graph, which will then automatically parallelize tasks as appropriate
([doc](https://mise.jdx.dev/tasks/architecture.html)).
