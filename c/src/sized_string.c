#include <stdlib.h>
#include <stdio.h>
#include <memory.h>
#include "sized_string.h"

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
