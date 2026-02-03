# Change directory to dynarr-asm

as dynarr.asm -o dynarr.o
gcc -g -c test.c -o test.o
gcc test.o dynarr.o -o test
./test