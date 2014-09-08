SOURCE_DIR = ./CinyTest/CinyTest
BUILD_DIR = ./makebuild
OBJ_DIR = $(BUILD_DIR)/obj
LIB_DIR = $(BUILD_DIR)/lib
INC_DIR = $(BUILD_DIR)/include/cinytest

CC = gcc
CFLAGS = -Wall -Os -std=c11 -I$(SOURCE_DIR)

HEADER_FILES = $(addprefix $(SOURCE_DIR)/,ciny.h)
SOURCE_FILES = $(addprefix $(SOURCE_DIR)/,ciny.c ciny_posix.c)
OBJ_FILES = $(addprefix $(OBJ_DIR)/,ciny.o ciny_posix.o)
LIB_FILE = libcinytest.a

$(OBJ_DIR)/%.o: $(SOURCE_DIR)/%.c $(HEADER_FILES) | $(OBJ_DIR)
	$(CC) -c -o $@ $< $(CFLAGS)

build: $(OBJ_FILES)
	mkdir -p $(LIB_DIR)
	ar rsv $(LIB_DIR)/$(LIB_FILE) $(OBJ_FILES)
	mkdir -p $(INC_DIR)
	cp $(HEADER_FILES) $(INC_DIR)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

.PHONY: clean
.PHONY: rebuild

clean:
	rm -rf $(BUILD_DIR)

rebuild: clean build
