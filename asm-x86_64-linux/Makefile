target/main: target/main.o
	ld.lld main.o -o target/main

target/main.o: main.asm
	nasm -f elf64 main.asm -o target/main.o

run: target/main
	./main

debug: target/main
	lldb ./target/main

