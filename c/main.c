#include <memory.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct JumpAddress {
	struct JumpAddress *prev_address;
	int addr;
} JumpAddress;

typedef struct SizedString {
	int len;
	char *str;
} SizedString;

SizedString *new_sized_string(char first_val) {
	SizedString *s = malloc(sizeof(SizedString));
	s->len = 1;
	s->str = malloc(sizeof(char));
	s->str[0] = first_val;

	return s;
}

SizedString *sized_string_copy(SizedString str) {
	SizedString *ss = malloc(sizeof(SizedString));
	ss->len = str.len;
	ss->str = malloc((sizeof(char)) * ss->len);
	memcpy((void *) ss->str, (void *) str.str, sizeof(char) * ss->len);

	return ss;
}

void sized_string_append(SizedString *s, char ch) {
	s->len++;
	s->str = realloc(s->str, sizeof(char) * (s->len));
	s->str[s->len - 1] = ch;
}

void free_sized_string(SizedString *s) {
	free((void *) s->str);
	free((void *) s);
}

void print_sized_str(SizedString *s) {
	SizedString *ss2 = sized_string_copy(*s);
	sized_string_append(ss2, '\0');
	printf("%s\n", ss2->str);

	free_sized_string(ss2);
}

SizedString *read_to_string(char *path) {
	// Variable moment
	FILE *fp;
	char ch;

	// Open file and get first char
	fp = fopen(path, "r");
	ch = fgetc(fp);

	// Create a new SizedString to go brrr
	SizedString *ss = NULL;

	// Parser go brrr
	while (ch != EOF && ch != '\0') {
		switch (ch) {
			case '+':
			case '-':
			case '>':
			case '<':
			case '[':
			case ']':
			case ',':
			case '.':
				if (ss == NULL) {
					ss = new_sized_string(ch);
				} else {
					sized_string_append(ss, ch);
				}
			default:
				ch = fgetc(fp);
				break;
		}
	}

	// Close the file
	fclose(fp);

	return ss;
}

void run(SizedString *code) {
	char mem[30000];
	int ptr = 0;

	JumpAddress* jmp = NULL;

	int addr = 0;

	while (addr < code->len) {
		printf("%c", code->str[addr]);
		int temp = 0;
		JumpAddress* newJmp;

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
				printf("%d\n", (int) mem[ptr]);
				break;
			case ',':
				scanf("%X", &temp);
				mem[addr] = (char) temp;
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

int main(void) {
	SizedString *ss = read_to_string("example.bf");

	print_sized_str(ss);

	run(ss);

	return 0;
}
