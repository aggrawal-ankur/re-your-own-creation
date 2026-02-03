# Change directory to dynarr-asm

as opt-dynarr.asm -o opt-dynarr.o
gcc test.o opt-dynarr.o -o test
./test
rm test opt-dynarr.o