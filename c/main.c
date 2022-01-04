#include <memory.h>
#include <stdio.h>
#include <stdlib.h>
#include "sized_string.h"
#include "runner.h"

SizedString *read_to_string(char *);

void print_help(void);

void print_about(void);

int main(int argc, char *argv[]) {
	char ascii = 1;
	char verbose = 0;
	char help = 0;

	char *file = NULL;

	if (argc < 2) {
		print_about();

		printf("\nError: Please specify a file\n");

		print_help();

		return 1;
	}

	{
		int i;
		for (i = 1; i < argc; i++) {
			if (strcmp(argv[i], "--number") == 0 || strcmp(argv[i], "-n") == 0) {
				ascii = 0;
			} else if (strcmp(argv[i], "--verbose") == 0 || strcmp(argv[i], "-v") == 0) {
				verbose = 1;
			} else if (strcmp(argv[i], "--help") == 0 || strcmp(argv[i], "-h") == 0) {
				help = 1;
			} else {
				file = argv[i];
			}
		}
	}

	if (help) {
		print_about();
		printf("\n");
		print_help();
		return 0;
	}

	if (file == NULL) {
		print_about();

		printf("\nError: Please specify a file\n");

		print_help();

		return 2;
	}

	SizedString *ss = read_to_string(file);

	if (verbose) {
		printf("Source Code: ");
		print_sized_str(ss);
	}

	if (ascii) {
		run_ascii(ss, verbose);
	} else {
		run(ss, verbose);
	}

	return 0;
}

SizedString *read_to_string(char *path) {
	// Variable moment
	FILE *fp;
	char ch;

	// Open file and get first char
	fp = fopen(path, "r");
	ch = (char) fgetc(fp);

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

void print_about(void) {
	printf("Bf in rosetta C\n");
	printf("A BrainFuck interpreter written in C, badly");
	printf("Version: 1.0.0\n");
	printf("Author: Nathan Hare<me@laspruca.nz>\n");
}

void print_help(void) {
	printf("Usage: bf-c [opts] <file>\n");
	printf("file: The file to be interpreted\n");
	printf("opts:\n");
	printf("\t--help, -h: prints the help message, this screen\n");
	printf("\t--verbose, -v: enables verbose printing\n");
	printf("\t--number, -n: interprets input and output as numbers, not ascii\n");
}
