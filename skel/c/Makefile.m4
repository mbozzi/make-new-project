 # Does an in-source build of C code only.
TARGET = ./projectname

WFLAGS	 += -Wall -Wextra -pedantic
CFLAGS += $(WFLAGS) -Og -ggdb -fno-omit-frame-pointer --std=c11
C_SRC_EXT = c

override LIBS += $(addprefix -l,$(LDLIBS))

# Look for the source code here
SRC_DIR = .
$(shell mkdir -p $(SRC_DIR))

# Put the build files here
BUILD_DIR = ../build

# Make sure the build and source directories exists and then clone _only the
# sub-directories_ of that source code tree into the intermediate build tree.
$(shell mkdir -p $(BUILD_DIR))
$(shell find $(SRC_DIR) -type d -exec mkdir -p -- $(BUILD_DIR)/{} \;)

# Grab all C++ sources below the source directory.
SRCS = $(shell find $(SRC_DIR) -name '*.$(C_SRC_EXT)' -type f)
OBJS = $(subst $(SRC_DIR)/,$(BUILD_DIR)/,$(SRCS:.$(C_SRC_EXT)=.o))

ifeq ($(strip $(SRCS)),)
$(error No source code found below './$(SRC_DIR)'!  I look for files ending in	\
'.$(C_SRC_EXT)')
endif

$(TARGET): $(OBJS)
	$(CC) $(OUTPUT_OPTION) $(LDFLAGS) $(LIBS) $(WFLAGS) $^

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.$(C_SRC_EXT)
	$(CC) $(OUTPUT_OPTION) -MT $@ -MP -MMD -MF $(@:.o=.d) $(CFLAGS) \
	$(CPPFLAGS) -c $<

.PHONY: all
all: $(TARGET)

AUTODEPS = $(OBJS:.o=.d)

.PHONY: clean
clean:
	-rm -f $(OBJS) $(TARGET) $(AUTODEPS)

.PRECIOUS: $(AUTODEPS)
-include $(AUTODEPS)
