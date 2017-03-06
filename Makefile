OS_TARGET := $(shell uname)
SRC_DIR := src
SAMP_SRC_DIR := $(SRC_DIR)/sample
SAMP_TESTSRC_DIR := test/sample
BUILD_DIR := build
OBJ_DIR := $(BUILD_DIR)/obj
LIB_DIR := $(BUILD_DIR)/lib
INC_DIR := $(BUILD_DIR)/include

CC := gcc
CFLAGS := -Wall -Wextra -Werror -pedantic -std=c11
SP := strip
SPFLAGS := -s
ARFLAGS := -rsv

HEADER_FILES := $(addprefix $(SRC_DIR)/,ciny.h)
SRC_FILES := $(addprefix $(SRC_DIR)/,ciny.c ciny_posix.c)
OBJ_FILES := $(addprefix $(OBJ_DIR)/,ciny.o ciny_posix.o)
SAMP_SRC_FILES := $(SAMP_SRC_DIR)/binarytree.c
LIB_TARGET := libcinytest.a
SAMP_TARGET := sample
SAMPT_TARGET := sampletests

ifeq ($(OS_TARGET), Darwin)
CC := clang
SPFLAGS := -
endif

ifdef XCFLAGS
CFLAGS += $(XCFLAGS)
endif

.PHONY: release debug buildall build buildsample buildsampletests check clean

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c $(HEADER_FILES) | $(OBJ_DIR)
	$(CC) $(CFLAGS) -iquote$(SRC_DIR) -c $< -o $@

release: CFLAGS += -Os
release: buildall
	$(SP) $(SPFLAGS) $(BUILD_DIR)/$(SAMP_TARGET)
	$(SP) $(SPFLAGS) $(BUILD_DIR)/$(SAMPT_TARGET)

debug: CFLAGS += -g -O0 -DDEBUG
debug: buildall

buildall: build buildsample buildsampletests

build: $(OBJ_FILES)
	mkdir -p $(LIB_DIR)
	$(AR) $(ARFLAGS) $(LIB_DIR)/$(LIB_TARGET) $(OBJ_FILES)
	mkdir -p $(INC_DIR)
	cp $(HEADER_FILES) $(INC_DIR)

buildsample: SAMP_SRC_FILES += $(SAMP_SRC_DIR)/main.c
buildsample:
	$(CC) $(CFLAGS) $(SAMP_SRC_FILES) -o $(BUILD_DIR)/$(SAMP_TARGET)

# suppress ISO C99 variadic macro at-least-one-argument warning
ifeq ($(CC), clang)
buildsampletests: CFLAGS += -Wno-gnu-zero-variadic-macro-arguments
else
buildsampletests: CFLAGS += -Wno-pedantic
endif
buildsampletests: CFLAGS += -Wno-unused-parameter -iquote$(BUILD_DIR)/include -iquote$(SAMP_SRC_DIR)
buildsampletests: LDFLAGS := -L$(LIB_DIR)
buildsampletests: LDLIBS := -lcinytest
buildsampletests: SAMP_SRC_FILES += $(SAMP_TESTSRC_DIR)/main.c $(SAMP_TESTSRC_DIR)/binarytree_tests.c
buildsampletests:
	$(CC) $(CFLAGS) $(SAMP_SRC_FILES) $(LDFLAGS) $(LDLIBS) -o $(BUILD_DIR)/$(SAMPT_TARGET)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

check:
	$(BUILD_DIR)/$(SAMPT_TARGET)

clean:
	$(RM) -r $(BUILD_DIR)
