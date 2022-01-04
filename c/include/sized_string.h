#ifndef STRING_SIZE_H
#define STRING_SIZE_H

typedef struct SizedString {
	int len;
	char *str;
} SizedString;

SizedString *new_sized_string(char first_val);

SizedString *sized_string_copy(SizedString str);

void sized_string_append(SizedString *s, char ch);

void free_sized_string(SizedString *s);

void print_sized_str(SizedString *s);

#endif