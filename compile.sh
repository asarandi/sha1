#!/bin/bash
rm -f sha1.o test

os=`uname -s`

if [ "$os" == "Linux" ]; then
    nasm -f elf64 sha1.asm
fi

if [ "$os" == "Darwin" ]; then
    nasm -f macho64 sha1.asm
fi

cc -I. main.c sha1.o -o sha1
