as dynstr.asm -o dynstr.o
gcc -c tests.c -o tests.o
gcc dynstr.o tests.o -o main
./main
rm main dynstr.o tests.o