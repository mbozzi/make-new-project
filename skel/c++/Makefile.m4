\# Copyright (C) 2015-2016 Max Bozzi <mjb@mbozzi.com>
\#
\# This file is part of projectname.
\#
\# projectname is free software: you can redistribute it and/or modify it under
\# the terms of the GNU General Public License as published by the Free Software
\# Foundation, either version 3 of the License, or (at your option) any later
\# version.
\#
\# projectname is distributed in the hope that it will be useful, but WITHOUT ANY
\# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
\# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
\#
\# You should have received a copy of the GNU General Public License along with
\# projectname.  If not, see <http://www.gnu.org/licenses/>.

\# Where should I place the ELF version of the program (compiler's output)?
ELF = ./projectname

\# What static libraries should I link into the code?
LIBS = c

\# What are the names of the following programs?
\# override CXX	 = g++
\# override CC	 = gcc
\# override OBJCOPY = objcopy
\# override AS	 = as
\# override AR	 = ar
\# override LD	 = ld

\# What compiler flags should I pass?
WFLAGS   += -Wall -Wextra -pedantic
CXXFLAGS += $(WFLAGS) -Os -fno-omit-frame-pointer --std=c++14	\
	    -funsigned-char -fshort-enums -funsigned-bitfields	\
	    -ffunction-sections -fdata-sections

CFLAGS += $(WFLAGS) -Os -fno-omit-frame-pointer --std=c11	\
	  -funsigned-char -fshort-enums -funsigned-bitfields	\

\# What assembler flags should I use?
SFLAGS =

\# What linker flags should I use?
LDFLAGS += -L. -Wl,--gc-sections

\# What flags should I pass to objcopy?
OBJCOPY_FLAGS = --set-section-flags=.eeprom=alloc,load --no-change-warnings	\
	        --change-section-lma .eeprom=0

\# What extension does your C++ source code end in?
CXX_SRC_EXT = cxx

\# What extension does your C source code end in?
C_SRC_EXT = c

\# What extension does your assembler code end in?
ASM_SRC_EXT = S

\# Where should I search for the source code?
\#
\# The source code directory serves as the root of a tree below which each source
\# file in every subtree is compiled.
\#
\# It is assumed that all the source code is beneath a single directory.
SRC_DIR = src
$(shell mkdir -p $(SRC_DIR))

\# Where should I place the build files?
\#
\# The build directory serves as the root of a tree which mirrors the source
\# tree.	 Intermediate build files (object code, etc.) are placed in the build
\# directory corresponding to their position in the source tree.	 The function
\# `mirror-dir-skeleton' provides this functionality.
\#
\# An out-of-source build is default, but an in-source build will occur when the
\# value of SRC_DIR and BUILD_DIR are the same.
\#
\# If you accidentially pollute the wrong directory with build files, you can
\# hope that there were no name collisions (which has to overwrite your files)
\# and call the `clean' target to remove just those files.
BUILD_DIR = ./build

\# What should I call the tags file?
TAGFILE = ./TAGS

\# Duplicate "mirror" the skeleton of sub-directories from $(1) into $(2).
\# For example, the invocation
\# $(call mirror-dir-skeleton,$(SRC_DIR),$(BUILD_DIR))
\#
\# will place empty copies of all the subdirectories beneath $(SRC_DIR) into
\# $(BUILD_DIR).
mirror-dir-skeleton = $(foreach dir,$(shell (cd $(1) && find . -type d)),	\
			   $(shell mkdir -p $(2)/$(dir)))

$(call mirror-dir-skeleton,$(SRC_DIR),$(BUILD_DIR))

DOC_DIR = ./doc

\# Make sure that libraries specified here are built for AVR.
override LDLIBS += $(addprefix -l,$(LIBS))

\# Make sure the build and source directories exist and then clone _only the
\# sub-directories_ of that source code tree into the intermediate build tree.

\# Grab all sources below the source directory.
CXX_SRCS = $(shell find $(SRC_DIR) -name '*.$(CXX_SRC_EXT)' -type f)
C_SRCS   = $(shell find $(SRC_DIR) -name '*.$(C_SRC_EXT)' -type f)


SRCS = $(shell find $(SRC_DIR) -name '*.$(CXX_SRC_EXT)' -or -name		\
	'*.$(C_SRC_EXT)' -or -name '*.$(ASM_SRC_EXT)' -type f)
OBJS = $(subst $(SRC_DIR)/,$(BUILD_DIR)/,$(addsuffix .o,$(SRCS)))

\# Check to see if I have found any source code at all.
ifeq ($(strip $(SRCS)),)
$(error No source code found below './$(SRC_DIR)'.  I look for files ending in	\
'.$(CXX_SRC_EXT)')
endif

\# Compile a specific, C++ object file by name relative to the project root.
\$(BUILD_DIR)/%.$(CXX_SRC_EXT).o: $(SRC_DIR)/%.$(CXX_SRC_EXT)
\# Compile, but as a side effect, generate header-file dependency information and
\# place it adjacent to the object files in the build skeleton.
	$(CXX) $(OUTPUT_OPTION) -MT $@ -MP -MMD -MF $(@:.o=.d) $(CXXFLAGS)	\
	$(CPPFLAGS) -c $<

\# Same thing, but for C code.
$(BUILD_DIR)/%.$(C_SRC_EXT).o: $(SRC_DIR)/%.$(C_SRC_EXT)
	$(CC) $(OUTPUT_OPTION) -MT $@ -MP -MMD -MF $(@:.o=.d) $(CFLAGS)		\
	$(CPPFLAGS) -c $<

\# And for assembler.
$(BUILD_DIR)/%.$(ASM_SRC_EXT).o: $(SRC_DIR)/%.$(ASM_SRC_EXT)
	$(CC) $(OUTPUT_OPTION) $(SFLAGS) -c $<

\# Compute the names of the auto-dependency files.
AUTODEPS = $(OBJS:.o=.d)

\# Command targets always run.
\# Compile the source code into an Intel Hex file ready to upload.
.PHONY: elf
elf: $(ELF)

.PHONY: all
all: $(ELF) docs tags

.PHONY: elf
elf: $(ELF)

\# Build all the object files.
.PHONY: object
object: $(OBJS)

\# Delete the build tree and any generated files, preserving the source code.
\#
\# Due to the automatic dependency resolution, this is not normally necessary.
.PHONY: clean
clean:
	-rm -f 	$(ELF)
	-rm -f 	$(OBJS)
	-rm -f 	$(AUTODEPS)
	-rm -rf $(TAGFILE)

\# Link the compiled object files and any libraries together.
$(ELF): $(OBJS)
	$(CXX) $(OUTPUT_OPTION) $(LDFLAGS) $(WFLAGS) $^ $(LDLIBS)

# Run etags in the source directory.
.PHONY: tags
tags:
	etags -e -R -f $(TAGFILE) $(wildcard $(SRC_DIR)/*)

\# Automatically generate documentation.
docs: $(SRCS)
	doxygen

.PRECIOUS: $(AUTODEPS)
.DELETE_ON_ERROR: $(HEX) $(ELF)

\# Pull in generated auto-dependency information so that source files are
\# recompiled when their corresponding header files change.
\#
\# $(AUTODEPS) contains the files generated by the compilation of the arduino
\# core, if it has been compiled at all.
-include $(AUTODEPS)
