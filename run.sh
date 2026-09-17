[ ! -d "bin" ] && mkdir bin

#as main.S -o bin/main.o -g

#ld bin/main.o -o bin/main

gcc main.c -o bin/main -g -lm

chmod +x ./bin/main

./bin/main

echo $?