#!/bin/bash
# Copyright (C) 2017 Max Bozzi <mjb@mbozzi.com>

set -x

gtags
git init .
git add Makefile src
git add Doxyfile
git add LICENSE
git add .gitignore .gitattributes

chmod 444 LICENSE
