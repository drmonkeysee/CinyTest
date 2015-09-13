SRC_DIR := ./CinyTest/CinyTest
BUILD_DIR := ./build
OBJ_DIR := $(BUILD_DIR)/obj
LIB_DIR := $(BUILD_DIR)/lib
INC_DIR := $(BUILD_DIR)/include/cinytest

CC := gcc
CFLAGS := -Wall -Wextra -pedantic -Os -std=c11

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

testsample: TEST_SRC_DIR := ./CinyTest-Sample/CinyTest-Sample
testsample: TEST_TESTSRC_DIR := ./CinyTest-Sample/CinyTest-SampleTests
testsample: CFLAGS += -Wno-gnu-zero-variadic-macro-arguments -Wno-unused-parameter -I$(BUILD_DIR)/include -I$(TEST_SRC_DIR)
testsample: LDFLAGS := -L$(LIB_DIR) -lcinytest
testsample: TEST_SRC_FILES := $(TEST_SRC_DIR)/binarytree.c $(TEST_TESTSRC_DIR)/main.c $(TEST_TESTSRC_DIR)/binarytree_tests.c
testsample: TEST_TARGET := sampletests
testsample: build
	$(CC) $(CFLAGS) $(LDFLAGS) $(TEST_SRC_FILES) -o $(BUILD_DIR)/$(TEST_TARGET)
	$(BUILD_DIR)/$(TEST_TARGET)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

clean:
	rm -rf $(BUILD_DIR)

rebuild: clean build
