SRC_DIR := src
BUILD_DIR := build
OBJ_DIR := $(BUILD_DIR)/obj
LIB_DIR := $(BUILD_DIR)/lib
INC_DIR := $(BUILD_DIR)/include/cinytest

CC := gcc
CFLAGS := -Wall -Wextra -pedantic -Os -std=c11 $(XCFLAGS)

HEADER_FILES := $(addprefix $(SRC_DIR)/,ciny.h)
SRC_FILES := $(addprefix $(SRC_DIR)/,ciny.c ciny_posix.c)
OBJ_FILES := $(addprefix $(OBJ_DIR)/,ciny.o ciny_posix.o)
LIB_FILE := libcinytest.a
ARFLAGS := -rsv

.PHONY: build clean rebuild testsample

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c $(HEADER_FILES) | $(OBJ_DIR)
	$(CC) $(CFLAGS) -I$(SRC_DIR) -c $< -o $@

build: $(OBJ_FILES)
	mkdir -p $(LIB_DIR)
	$(AR) $(ARFLAGS) $(LIB_DIR)/$(LIB_FILE) $(OBJ_FILES)
	mkdir -p $(INC_DIR)
	cp $(HEADER_FILES) $(INC_DIR)

testsample: SAMP_SRC_DIR := src/sample
testsample: SAMP_TESTSRC_DIR := test/sample
testsample: CFLAGS += -Wno-gnu-zero-variadic-macro-arguments -Wno-unused-parameter -I$(BUILD_DIR)/include -I$(SAMP_SRC_DIR)
testsample: LDFLAGS := -L$(LIB_DIR) -lcinytest
testsample: SAMP_SRC_FILES := $(SAMP_SRC_DIR)/binarytree.c $(SAMP_TESTSRC_DIR)/main.c $(SAMP_TESTSRC_DIR)/binarytree_tests.c
testsample: SAMP_TARGET := sampletests
testsample: build
	$(CC) $(CFLAGS) $(SAMP_SRC_FILES) $(LDFLAGS) -o $(BUILD_DIR)/$(SAMP_TARGET)
	$(BUILD_DIR)/$(SAMP_TARGET)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

clean:
	rm -rf $(BUILD_DIR)

rebuild: clean build
