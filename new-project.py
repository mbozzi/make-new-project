#!/usr/bin/env python

# Copyright (C) 2015-2016 Max Bozzi <mjb@mbozzi.com>
#
# This file is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This file is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# This file.  If not, see <http://www.gnu.org/licenses/>.

import argparse
import sys
import os
from os.path import *
from subprocess import run

def make_proj_root(args):
    proj_root = join(args.directory, args.name)
    os.mkdir(proj_root)
    return proj_root

def check_skel_root(args):
    skel_root = args.skeleton_dir
    if not (isdir(skel_root)):
        print("error: can't find skeletons in '{}': not a directory".format(skel_root))
        exit(1)

    skel_root = join(skel_root, args.type)
    if not (isdir(skel_root)):
        print("error: in '{}': can't find a skeleton named '{}'"
              .format(args.skeleton_dir, args.type))
        exit(1)
    return skel_root

def check_target_dir(args):
    target_dir = args.directory;
    if not (isdir(target_dir)):
        print("error: can't create a project in '{}': not a directory".format(target_dir))
        exit(1)
    return target_dir

def create_project(args):
    target_dir = check_target_dir(args)
    skel_root  = check_skel_root(args)
    proj_root  = make_proj_root(args)

    # Mirror the directory structure.
    for _, dirs, _ in os.walk(skel_root):
        for d in dirs:
            # We should have already created the project root.
            os.mkdir(join(proj_root, d))

    # Does this file need to be processed by M4?
    def needs_m4(file_name):
        return splitext(file_name)[1] == ".m4"

    # Compute the destination file from the source in the skeleton.  We're using
    # GNU M4 to process files; source file extensions which end in ".m4" will
    # have that extension stripped.
    #
    # If file_name doesn't have an associated directory, then the result refers
    # to a file in the project root.
    def project_path_and_name(file_name):
        result_name = basename(file_name)
        result_name = splitext(result_name)[0] if needs_m4(result_name) else result_name

        # Handle the case where the file's basename starts with projectname.
        # This should be done differently:
        #
        # For every file beneath the project root, do a simple text-replace for
        # projectname with the name of the project; do the move.
        if result_name[0:len("projectname")] == "projectname":
            result_name = args.name + splitext(result_name)[1]

        proj_subdir = join (proj_root, relpath (dirname(file_name), skel_root) + "/")
        return join(proj_subdir, result_name)

    def skeleton_subdir(skel_sub):
        return relpath(skel_sub, skel_root)

    for skel_sub, dirs, files in os.walk(skel_root, topdown=False):
        names = []
        for f in files:
            file_path = join(skel_sub, f)
            names.append( (file_path, project_path_and_name(file_path)) )

        for source, dest in names:
            assert(not exists(dest)) # Don't nuke a file that already exists!
            command = "m4 -Dprojectname='{}' '{}' > '{}'".format(args.name, source, dest)
            print (command)
            # Issue the command.
            os.system(command)

def list_projects(args):
    for d in next(os.walk(args.skeleton_dir))[1]:
        print (d)

if __name__ == "__main__":
    parser        = argparse.ArgumentParser(description="Create or list new project skeletons.")
    subparsers    = parser.add_subparsers(dest='command')
    subparsers.required = True

    list_parser = subparsers.add_parser('list')
    list_parser.set_defaults(func=list_projects)
    list_parser.add_argument("-s", "--skeleton-dir",
                             help="look for project skeletons in the given directory",
                             default=os.getenv("HOME") + "/prj/make-new-project/skel/")

    create_parser = subparsers.add_parser('create')
    create_parser.set_defaults(func=create_project)
    create_parser.add_argument("-d", "--directory",
                               help="create a new project in the given directory",
                               default=os.getenv("HOME") + "/prj/")
    create_parser.add_argument("-s", "--skeleton-dir",
                               help="look for project skeletons in the given directory",
                               default=os.getenv("HOME") + "/prj/make-new-project/skel/")
    create_parser.add_argument("type",
                               help="create a new project of the given type")
    create_parser.add_argument("name",
                               help="create a new project with the given name")

    args = parser.parse_args()
    args.func(args)
