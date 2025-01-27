target/main: target/main.o
	ld.lld target/main.o -o target/main

target/main.o: main.asm
	nasm -Fdwarf -f elf64 main.asm -o target/main.o

run: target/main
	./target/main

run-fib: target/main
	./target/main -n ../exampleCode.bf

debug: target/main
	lldb ./target/main

