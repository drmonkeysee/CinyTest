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

PUB_HEADER := ciny.h
HEADER_FILES := $(addprefix $(SRC_DIR)/,$(PUB_HEADER))
SOURCES := ciny.c ciny_posix.c
SRC_FILES := $(addprefix $(SRC_DIR)/,$(SOURCES))
OBJ_FILES := $(addprefix $(OBJ_DIR)/,$(SOURCES:.c=.o))
SAMP_SRC_FILES := $(SAMP_SRC_DIR)/binarytree.c
LIB_NAME := libcinytest
LIB_TARGET := $(LIB_NAME).a
DYLIB_VERSION := 10.0.2
DYLIB_MAJOR := $(firstword $(subst ., ,$(DYLIB_VERSION)))
SAMP_TARGET := ct_sample
SAMPT_TARGET := ct_sampletests

CFLAGS := -Wall -Wextra -Wconversion -pedantic -std=c23
SP := strip
ARFLAGS := -rsv

ifeq ($(OS_TARGET), Darwin)
SPFLAGS := -
DYLIB_SHORTNAME := $(LIB_NAME).dylib
DYLIB_MAJORNAME := $(LIB_NAME).$(DYLIB_MAJOR).dylib
DYLIB_NAME := $(LIB_NAME).$(DYLIB_VERSION).dylib
else
SPFLAGS := -s
DYLIB_SHORTNAME := $(LIB_NAME).so
DYLIB_MAJORNAME := $(LIB_NAME).so.$(DYLIB_MAJOR)
DYLIB_NAME := $(LIB_NAME).so.$(DYLIB_VERSION)
endif

ifdef XCFLAGS
CFLAGS += $(XCFLAGS)
endif

.PHONY: release debug buildall build buildshared buildsample buildsampletests \
		check install uninstall clean

release: CFLAGS += -Werror -Os -DNDEBUG
release: buildall
	$(SP) -x $(LIB_DIR)/$(DYLIB_NAME)
	$(SP) $(SPFLAGS) $(BUILD_DIR)/$(SAMP_TARGET)
	$(SP) $(SPFLAGS) $(BUILD_DIR)/$(SAMPT_TARGET)

debug: CFLAGS += -g -O0 -DDEBUG
debug: buildall

buildall: build buildshared buildsample buildsampletests

# gcc requires feature test for some posix functions and is touchier about ignoring file return values
ifneq ($(OS_TARGET), Darwin)
build: CFLAGS += -D_POSIX_C_SOURCE=199309L -Wno-unused-result
endif
build: $(OBJ_FILES)
	mkdir -p $(LIB_DIR)
	$(AR) $(ARFLAGS) $(LIB_DIR)/$(LIB_TARGET) $(OBJ_FILES)
	mkdir -p $(INC_DIR)
	cp $(HEADER_FILES) $(INC_DIR)

ifeq ($(OS_TARGET), Darwin)
buildshared: DYFLAGS := -dynamiclib -current_version $(DYLIB_VERSION) \
				-compatibility_version $(DYLIB_MAJOR) \
				-install_name $(INST_LIB)/$(DYLIB_NAME)
else
buildshared: CFLAGS += -D_POSIX_C_SOURCE=199309L -Wno-unused-result -fPIC
buildshared: DYFLAGS := -shared -Wl,-soname,$(DYLIB_MAJORNAME)
endif
buildshared:
	$(CC) $(CFLAGS) $(SRC_FILES) $(DYFLAGS) -o $(LIB_DIR)/$(DYLIB_NAME)

buildsample: SAMP_SRC_FILES += $(SAMP_SRC_DIR)/main.c
buildsample:
	$(CC) $(CFLAGS) $(SAMP_SRC_FILES) -o $(BUILD_DIR)/$(SAMP_TARGET)

# suppress ISO C99 variadic macro at-least-one-argument warning
ifeq ($(OS_TARGET), Darwin)
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

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c $(HEADER_FILES) | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

check:
	$(BUILD_DIR)/$(SAMPT_TARGET)

install:
	cp $(INC_DIR)/$(PUB_HEADER) $(INST_INC)
	cp $(LIB_DIR)/$(LIB_TARGET) $(INST_LIB)
	cp $(LIB_DIR)/$(DYLIB_NAME) $(INST_LIB)
	ln -sf $(DYLIB_NAME) $(INST_LIB)/$(DYLIB_MAJORNAME)
	ln -sf $(DYLIB_MAJORNAME) $(INST_LIB)/$(DYLIB_SHORTNAME)
ifneq ($(wildcard $(DOC_DIR)),)
	mkdir -p $(INST_DOC)
	cp -R $(DOC_DIR)/ $(INST_DOC)
endif

uninstall:
	$(RM) $(INST_INC)/$(PUB_HEADER)
	$(RM) $(INST_LIB)/$(LIB_NAME).*
	$(RM) -r $(INST_DOC)

clean:
	$(RM) -r $(BUILD_DIR)
