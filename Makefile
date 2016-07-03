OS_TARGET := $(shell uname)
SRC_DIR := src
SAMP_SRC_DIR := $(SRC_DIR)/sample
SAMP_TESTSRC_DIR := test/sample
BUILD_DIR := build
OBJ_DIR := $(BUILD_DIR)/obj
LIB_DIR := $(BUILD_DIR)/lib
INC_DIR := $(BUILD_DIR)/include/cinytest

CC := gcc
CFLAGS := -Wall -Wextra -pedantic -std=c11
SP := strip
SPFLAGS := -s
ARFLAGS := -rsv

HEADER_FILES := $(addprefix $(SRC_DIR)/,ciny.h)
SRC_FILES := $(addprefix $(SRC_DIR)/,ciny.c ciny_posix.c)
OBJ_FILES := $(addprefix $(OBJ_DIR)/,ciny.o ciny_posix.o)
SAMP_SRC_FILES := $(SAMP_SRC_DIR)/binarytree.c
LIB_TARGET := libcinytest.a
BT_TARGET := btrun
SAMP_TARGET := sampletests

ifeq ($(OS_TARGET), Darwin)
CC := clang
SPFLAGS := -
endif

ifdef XCFLAGS
CFLAGS += $(XCFLAGS)
endif

.PHONY: release debug buildall build buildbt buildbttests check clean

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c $(HEADER_FILES) | $(OBJ_DIR)
	$(CC) $(CFLAGS) -I$(SRC_DIR) -c $< -o $@

release: CFLAGS += -Os
release: buildall
	$(SP) $(SPFLAGS) $(BUILD_DIR)/$(BT_TARGET)
	$(SP) $(SPFLAGS) $(BUILD_DIR)/$(SAMP_TARGET)

debug: CFLAGS += -g -O0 -DDEBUG
debug: buildall

buildall: build buildbt buildbttests

build: $(OBJ_FILES)
	mkdir -p $(LIB_DIR)
	$(AR) $(ARFLAGS) $(LIB_DIR)/$(LIB_TARGET) $(OBJ_FILES)
	mkdir -p $(INC_DIR)
	cp $(HEADER_FILES) $(INC_DIR)

buildbt: SAMP_SRC_FILES += $(SAMP_SRC_DIR)/main.c
buildbt:
	$(CC) $(CFLAGS) $(SAMP_SRC_FILES) -o $(BUILD_DIR)/$(BT_TARGET)

# suppress ISO C99 variadic macro at-least-one-argument warning
ifeq ($(CC), clang)
buildbttests: CFLAGS += -Wno-gnu-zero-variadic-macro-arguments
else
buildbttests: CFLAGS += -Wno-pedantic
endif
buildbttests: CFLAGS += -Wno-unused-parameter -I$(BUILD_DIR)/include -I$(SAMP_SRC_DIR)
buildbttests: LDFLAGS := -L$(LIB_DIR)
buildbttests: LDLIBS := -lcinytest
buildbttests: SAMP_SRC_FILES += $(SAMP_TESTSRC_DIR)/main.c $(SAMP_TESTSRC_DIR)/binarytree_tests.c
buildbttests:
	$(CC) $(CFLAGS) $(SAMP_SRC_FILES) $(LDFLAGS) $(LDLIBS) -o $(BUILD_DIR)/$(SAMP_TARGET)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

check:
	$(BUILD_DIR)/$(SAMP_TARGET)

clean:
	$(RM) -r $(BUILD_DIR)
