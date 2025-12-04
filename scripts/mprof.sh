#!/bin/bash

scriptdir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]:-$0}")")
. "$scriptdir/pypath.sh"

## run memory-profiler and open graph
# (FigureCanvasAgg is non-interactive. need to config gui to launch window)
#mprof run pytest -s --disable-warnings "$PROJ_SRC/tests/"
#mprof plot --flame

## run memory-profiler and print analysis
# (prints blank right now. not sure why)
#python -m memory_profiler pytest src/tests
