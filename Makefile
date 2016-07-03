OS_TARGET := $(shell uname)
SRC_DIR := src
BUILD_DIR := build
OBJ_DIR := $(BUILD_DIR)/obj
LIB_DIR := $(BUILD_DIR)/lib
INC_DIR := $(BUILD_DIR)/include/cinytest

CC := gcc
CFLAGS := -Wall -Wextra -pedantic -std=c11
SP := strip

HEADER_FILES := $(addprefix $(SRC_DIR)/,ciny.h)
SRC_FILES := $(addprefix $(SRC_DIR)/,ciny.c ciny_posix.c)
OBJ_FILES := $(addprefix $(OBJ_DIR)/,ciny.o ciny_posix.o)
LIB_TARGET := libcinytest.a
SAMP_TARGET := sampletests
ARFLAGS := -rsv

ifeq ($(OS_TARGET), Darwin)
MACOS := 1
endif

ifdef MACOS
CC := clang
endif

ifdef XCFLAGS
CFLAGS += $(XCFLAGS)
endif

ifndef SPFLAGS
ifdef MACOS
SPFLAGS := -
else
SPFLAGS := -s
endif
endif

.PHONY: release debug buildall build buildsample check clean

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c $(HEADER_FILES) | $(OBJ_DIR)
	$(CC) $(CFLAGS) -I$(SRC_DIR) -c $< -o $@

release: CFLAGS += -Os
release: buildall
	$(SP) $(SPFLAGS) $(BUILD_DIR)/$(SAMP_TARGET)

debug: CFLAGS += -g -O0 -DDEBUG
debug: buildall

buildall: build buildsample

build: $(OBJ_FILES)
	mkdir -p $(LIB_DIR)
	$(AR) $(ARFLAGS) $(LIB_DIR)/$(LIB_TARGET) $(OBJ_FILES)
	mkdir -p $(INC_DIR)
	cp $(HEADER_FILES) $(INC_DIR)

buildsample: SAMP_SRC_DIR := src/sample
buildsample: SAMP_TESTSRC_DIR := test/sample
buildsample: CFLAGS += -Wno-gnu-zero-variadic-macro-arguments -Wno-unused-parameter -I$(BUILD_DIR)/include -I$(SAMP_SRC_DIR)
buildsample: LDFLAGS := -L$(LIB_DIR)
buildsample: LDLIBS := -lcinytest
buildsample: SAMP_SRC_FILES := $(SAMP_SRC_DIR)/binarytree.c $(SAMP_TESTSRC_DIR)/main.c $(SAMP_TESTSRC_DIR)/binarytree_tests.c
buildsample:
	$(CC) $(CFLAGS) $(SAMP_SRC_FILES) $(LDFLAGS) $(LDLIBS) -o $(BUILD_DIR)/$(SAMP_TARGET)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

check:
	$(BUILD_DIR)/$(SAMP_TARGET)

clean:
	$(RM) -r $(BUILD_DIR)
