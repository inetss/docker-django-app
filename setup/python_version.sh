#!/bin/bash

PYTHON_MAJOR_VERSION=$($(cat /app/src/manage.py |head -n 1|tail -c +3) -c 'import sys; print(sys.version_info[0])')

case $PYTHON_MAJOR_VERSION in
2) PYTHON_SUFFIX="";;
3) PYTHON_SUFFIX="3";;
*) echo "src/manage.py must include a hashbang for a proper Python version"; exit 1;;
esac

python=python${PYTHON_SUFFIX}
