#!/bin/bash


die() { >&2 echo -e "$@\nAdd python executable to requirements.txt like this:\n# python: python3.5"; exit 1; }

python=$(cat requirements.txt | grep '^# python: ' | sed -re 's/.*://' | xargs)
[ -n "$python" ] || die "Could not discover python version"
python_exe=$(which "$python"; true)
[ -x "$python_exe" ] || die "Could not find python executable '${python}'"
export python=$python_exe
