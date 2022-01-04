#include <stdlib.h>
#include <stdio.h>
#include "runner.h"

typedef struct JumpAddress {
	struct JumpAddress *prev_address;
	int addr;
} JumpAddress;

void runner(SizedString*, char verbose, void(*print)(char), char (*read)(void));

char read_num(void) {
	// Create some temp variables
	char tmp[3], *ptr, dest;

	printf("> ");

	// Get user input and convert it to a number
	scanf("%3s", tmp);
	dest = (char) strtol(tmp, &ptr, 10);

	// Return the number
	return dest;
}

void print_num(char output) {
	printf("%d\n", output);
}

void run(SizedString *ss, char verbose) {
	runner(ss, verbose, print_num, read_num);
}

char read_char(void) {
	char tmp;
	printf("> ");
	scanf("%c", &tmp);
	return tmp;
}

void print_char(char ch) {
	printf("%c\n", ch);
}

void run_ascii(SizedString *ss, char verbose) {
	runner(ss, verbose, print_char, read_char);
}

void runner(SizedString *code, char verbose, void (*print)(char), char (*read)(void)) {
	char mem[30000];
	int ptr = 0;

	JumpAddress *jmp = NULL;

	int addr = 0;

	while (addr < code->len) {
		if (verbose) {
			printf("%c", code->str[addr]);
		}

		char temp = 0;
		JumpAddress *newJmp;

		switch (code->str[addr]) {
			case '+':
				mem[ptr]++;
				break;
			case '-':
				mem[ptr]--;
				break;
			case '>':
				ptr++;
				if (ptr > 29999) {
					ptr = 0;
				}
				break;
			case '<':
				ptr--;
				if (ptr < 0) {
					ptr = 29999;
				}
				break;
			case '.':
				print(mem[ptr]);
				break;
			case ',':
				mem[addr] = read();
				break;
			case '[':
				newJmp = malloc(sizeof(JumpAddress));
				newJmp->addr = addr;
				newJmp->prev_address = jmp;
				jmp = newJmp;
				break;
			case ']':
				if (mem[ptr] == '\0') {
					newJmp = jmp->prev_address;
					free(jmp);
					jmp = newJmp;
				} else {
					addr = jmp->addr;
				}
				break;
			default:
				break;
		}
		addr++;
	}
}
