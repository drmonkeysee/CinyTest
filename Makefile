SOURCE_DIR = ./CinyTest/CinyTest
BUILD_DIR = ./makebuild
OBJ_DIR = $(BUILD_DIR)/obj
LIB_DIR = $(BUILD_DIR)/lib
INC_DIR = $(BUILD_DIR)/include/cinytest

CC = gcc
CFLAGS = -Wall -Os -std=c11 -I$(SOURCE_DIR)

HEADER_FILES = $(SOURCE_DIR)/*.h
SOURCE_FILES = $(SOURCE_DIR)/*.c
OBJ_FILES = $(OBJ_DIR)/*.o
LIB_FILE = libcinytest.a

$(OBJ_DIR)/%.o: $(SOURCE_DIR)/%.c $(HEADER_FILES)
	mkdir -p $(@D)
	$(CC) -c -o $@ $< $(CFLAGS)

build: $(OBJ_FILES)
	mkdir -p $(LIB_DIR)
	ar rsv $(LIB_DIR)/$(LIB_FILE) $(OBJ_FILES)
	mkdir -p $(INC_DIR)
	cp $(HEADER_FILES) $(INC_DIR)

.PHONY: clean
.PHONY: rebuild

clean:
	rm -rf $(BUILD_DIR)

rebuild: clean build
