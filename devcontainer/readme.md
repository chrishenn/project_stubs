# devcontainer

stub project for using devcontainers

examples
https://github.com/JetBrains/devcontainers-examples/

So, you could do effectively the same thing with a bash script. Trigger the container build, mount the project repo,
attach a shell inside the container, etc.

The crappiness of that experience really comes down to:

- The frequency with which you (the dev) are manually interacting with the docker-container interface layer
- The performance overhead
- Various incompatibilities, where system tools simply won't interact correctly with binaries or libraries mounted into
  a container (for example, mounting a case-insensitive filesystem into a sensitive one)
- The broad drawbacks of having an additional software layer between you and your text files (this layer has some state
  that must be managed, updated, can become corrupt or incorrect, and has limited repeatability since it relies on other
  package managers - and on and on)

Jetbrains would like to address the first point, by having their devcontainer IDE plugin literally install itself into
the container. I would assume that the shell that's built into the IDE would then run inside the container as well.
However, a plugin can hardly be said to address the subsequent issues - in fact, adding another layer of software will
inevitably exacerbate the last point, if not the second.

All this to circumvent the atrocious state of linux package managers for development (and development packaging /
abi-compatibility / stability / flexibility as a whole).

---

For example, uv symlinks the .venv/bin/python to an installed python interpreter somewhere else. From the host, that
symlink is not valid. So you can't debug from both the host and container simultaneously. You would need to build the uv
environment from either the host or the container and use it from the same place.

So pycharm installs the "IDE backend" into the devcontainer. HOLY SHIT the cpu usage is INSANE JUST FROM EDITING TEXT
FILES. WAY more than I expected - like 30% of 16 zen5 cores.
