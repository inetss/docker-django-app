#!/bin/bash

die() { >&2 echo -e $@; exit 1; }

PYTHON_VARIANTS=$(cat /app/requirements.txt |grep '^# python: '| sed -re 's/.*://')
[ -n "$PYTHON_VARIANTS" ] || die "Add python variants to requirements.txt like this:\n# python: python3.5 python3.4"
for python in $PYTHON_VARIANTS; do python=$(which "$python"; true); if [ -n "$python" ]; then break; fi; done
[ -n "$python" ] || die "Could not find any of $PYTHON_VARIANTS"
