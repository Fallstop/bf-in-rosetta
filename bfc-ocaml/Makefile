# Default value (optional)
MODE := 

.PHONY: helloWorld exampleCode

# Target-specific variable assignments
helloWorld: MODE := --ascii
exampleCode: MODE := --b8

helloWorld:
	dune exec bfc -- ../helloWorld.bf $(MODE)
	nasm -Fdwarf -f elf64 -o helloWorld.o main.asm
	ld helloWorld.o -o helloWorld.bin

exampleCode:
	dune exec bfc -- ../exampleCode.bf $(MODE)
	nasm -Fdwarf -f elf64 -o exampleCode.o main.asm
	ld exampleCode.o -o exampleCode.bin