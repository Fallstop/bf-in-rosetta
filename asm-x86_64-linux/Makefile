target/main: target/main.o
	ld.lld target/main.o -o target/main

target/main.o: main.asm
	nasm -Fdwarf -f elf64 main.asm -o target/main.o

.PHONY: run
run: target/main
	./target/main ../helloWorld.bf

.PHONY: run-fib
run-fib: target/main
	./target/main -n ../exampleCode.bf

.PHONY: debug
debug: target/main
	lldb ./target/main

