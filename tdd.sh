#!/bin/sh

# Author: Jake Goodwin
# Date: 2023
# Description: Shell script to automate stuff with TDD


SRCDIR=./src
TESTDIR=./tests
INCLUDES=./include
SOURCE_EXT=c
TITLE="0"

UNITY_BASIC_FILE=unity_basic_code.c

# Prints out a line seperator for visual clarity.
print_line_seperator () {
    echo "##############################"
    if [ "${TITLE}" != "0" ]; then
        echo "${TITLE}"
    else
        echo "------------------------------"
    fi
    echo "##############################"

    # Now clear the TITLE variable
    TITLE="0"
}


# checks the SRC dir and then adds testing modules for every source file.
# If it already exists in the tests dir then it skips with a message.
add_test_modules () {
    TITLE="add_test_modules ()"
    print_line_seperator
    cd ${SRCDIR}
    echo "Using test dir: ${TESTDIR}"
    for file in *.c; do
        # Extra dot to pathname to check parent dir
        if [ -d .${TESTDIR}/${file%.*} ]; then
            echo "Directory already exists for: ${file%.*}, skipping..."
            continue
        fi
        mkdir .${TESTDIR}/${file%.*}
        touch .${TESTDIR}/${file%.*}/${file%.*}_test.c
        echo "Added test file: ${file%.*}_test.c into dir: ${file%.*}"  
    done
    cd ..
}

# Adds the neede heaeder include statments to the C file.
append_unity_headers () {
    echo "#include \"unity.h\"" >> ${F}
    echo "#include \"${FILE_HEADER}\"" >> ${F}
}

# Adds the basic code needed for TDD to the .c file
append_basic_code () {
    cat ${UNITY_BASIC_FILE} >> ${F}
}

# Adds stuff to all the unit testing files
append_basic_unity_files () {
    for F in ${D}/*.c; do
        echo "File: ${F}"
        LENGTH=$(wc -l ${F} | grep -o '^[0-9]* ')
        echo "LEN: ${LENGTH}"
        if [ "0" -lt "${LENGTH}" ]; then
            continue
        fi
        echo "Empty file!: adding template code..."
        FILE_HEADER="${F%_test.c}.h"
        FILE_HEADER=$(echo ${FILE_HEADER#./*/})
        echo "FILE_HEADER = ${FILE_HEADER}"
        append_unity_headers
        append_basic_code
    done
}

# Adds the headers, teardown, setup, etc
# basic stuff that you would normally have to manual type into it.
append_basic_unity_dirs () {
    TITLE="append_basic_unity_dirs ()"
    print_line_seperator
    cd ${TESTDIR}
    for D in ./*; do
        if [ -d ${D} ]; then
            echo "\nchecking subdir"
            append_basic_unity_files
        else
            # echo "Error: missing dir: ${D}"
            continue
        fi
    done
    cd ..
}

add_test_modules
append_basic_unity_dirs

