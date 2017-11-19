#!/bin/bash
# Copyright (C) 2017 Max Bozzi <mjb@mbozzi.com>

set -x

gtags

git add Makefile src
git add Doxyfile
git add .gitignore .gitattributes

rm LICENSE TODOs.org
