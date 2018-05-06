OS_TARGET := $(shell uname)
SRC_DIR := src
SAMP_SRC_DIR := $(SRC_DIR)/sample
SAMP_TESTSRC_DIR := test/sample
BUILD_DIR := build
OBJ_DIR := $(BUILD_DIR)/obj
LIB_DIR := $(BUILD_DIR)/lib
INC_DIR := $(BUILD_DIR)/include
DOC_DIR := doc/html
INST_DIR := /usr/local
INST_INC := $(INST_DIR)/include
INST_LIB := $(INST_DIR)/lib
INST_DOC := $(INST_DIR)/share/doc/cinytest

CC := gcc
CFLAGS := -Wall -Wextra -Werror -pedantic -std=c11
SP := strip
SPFLAGS := -s
ARFLAGS := -rsv

PUB_HEADER := ciny.h
HEADER_FILES := $(addprefix $(SRC_DIR)/,$(PUB_HEADER))
SOURCES := ciny.c ciny_posix.c
SRC_FILES := $(addprefix $(SRC_DIR)/,$(SOURCES))
OBJ_FILES := $(addprefix $(OBJ_DIR)/,$(SOURCES:.c=.o))
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

.PHONY: release debug buildall build buildsample buildsampletests check install uninstall clean

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c $(HEADER_FILES) | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

release: CFLAGS += -Os
release: buildall
	$(SP) $(SPFLAGS) $(BUILD_DIR)/$(SAMP_TARGET)
	$(SP) $(SPFLAGS) $(BUILD_DIR)/$(SAMPT_TARGET)

debug: CFLAGS += -g -O0 -DDEBUG
debug: buildall

buildall: build buildsample buildsampletests

# gcc requires feature test for file functions and is touchier about ignoring file return values
ifneq ($(CC), clang)
build: CFLAGS += -D_POSIX_C_SOURCE=1 -Wno-unused-result
endif
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

install:
	cp $(INC_DIR)/$(PUB_HEADER) $(INST_INC)
	cp $(LIB_DIR)/$(LIB_TARGET) $(INST_LIB)
ifneq ($(wildcard $(DOC_DIR)),)
	cp -R $(DOC_DIR)/ $(INST_DOC)
endif

uninstall:
	$(RM) $(INST_INC)/$(PUB_HEADER)
	$(RM) $(INST_LIB)/$(LIB_TARGET)
ifneq ($(wildcard $(INST_DOC)),)
	$(RM) -r $(INST_DOC)
endif

clean:
	$(RM) -r $(BUILD_DIR)
