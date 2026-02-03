# Change directory to dynarr-asm

as opt-dynarr.asm -o opt-dynarr.o
gcc -g -c test.c -o test.o
gcc test.o opt-dynarr.o -o test
./test