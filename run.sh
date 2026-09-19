[ ! -d "bin" ] && mkdir bin

as main.S -o bin/main.o

ld bin/main.o -o bin/main

chmod +x ./bin/main

./bin/main