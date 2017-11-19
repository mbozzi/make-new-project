# Copyright (C) 2017 Max Bozzi <mjb@mbozzi.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Where should I place the ELF version of the program (compiler's output)?
ELF = ./projectname
LDLIBS = $(shell sdl2-config --libs)
CXXFLAGS += -O2 -g -std=c++14 -Wall -Wextra -pedantic-errors -ftrapv  \
         -march=native $(shell sdl2-config --cflags)
LDFLAGS += -L. -Wl,--gc-sections

# Where should I search for the source code?
SRC_DIR = src
$(shell mkdir -p $(SRC_DIR))

# Where should I place the build files?
BUILD_DIR = ./build

# Duplicate "mirror" the skeleton of sub-directories from $(1) into $(2).
# For example, the invocation
# $(call mirror-dir-skeleton,$(SRC_DIR),$(BUILD_DIR))
#
# will place empty copies of all the subdirectories beneath $(SRC_DIR) into
# $(BUILD_DIR).
mirror-dir-skeleton = $(foreach dir,$(shell (cd $(1) && find . -type d)), \
				 $(shell mkdir -p $(2)/$(dir)))
$(call mirror-dir-skeleton,$(SRC_DIR),$(BUILD_DIR))

# Make sure the build and source directories exist and then clone _only the
# sub-directories_ of that source code tree into the intermediate build tree.

# Grab all sources below the source directory.
CXX_SRC_EXT = cxx
CXX_SRCS = $(shell find $(SRC_DIR) -name '*.$(CXX_SRC_EXT)' -type f)

SRCS = $(shell find $(SRC_DIR) -name '*.$(CXX_SRC_EXT)')
OBJS = $(subst $(SRC_DIR)/,$(BUILD_DIR)/,$(addsuffix .o,$(SRCS)))

# Check to see if I have found any source code at all.
ifeq ($(strip $(SRCS)),)
$(error No source code found below './$(SRC_DIR)'.	I look for files ending in	\
'.$(CXX_SRC_EXT)')
endif

.PHONY: elf
elf: $(ELF)
$(ELF): $(OBJS)
	$(CXX) $(OUTPUT_OPTION) $(LDFLAGS) $(WFLAGS) $^ $(LDLIBS)

# Compile a specific, C++ object file by name relative to the project root.
$(BUILD_DIR)/%.$(CXX_SRC_EXT).o: $(SRC_DIR)/%.$(CXX_SRC_EXT)
	$(CXX) $(OUTPUT_OPTION) -MT $@ -MP -MMD -MF $(@:.o=.d) $(CXXFLAGS)	\
	$(CPPFLAGS) -c $<

AUTODEPS = $(OBJS:.o=.d)

.PHONY: clean
clean:
	-rm -f	$(ELF)
	-rm -f	$(OBJS)
	-rm -f	$(AUTODEPS)

.PRECIOUS: $(AUTODEPS)
.DELETE_ON_ERROR: $(ELF)

-include $(AUTODEPS)
