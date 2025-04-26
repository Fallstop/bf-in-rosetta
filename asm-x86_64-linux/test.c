#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>

int main() {
  int fp = open("../hello-world.bf", O_RDONLY);
  if (fp == -1) {
    printf("Could not open file: %s\n", strerror(errno));
    return 0;
  }

  struct stat fp_size;

  fstat(fp, &fp_size);

  char *value = mmap(0, fp_size.st_size, PROT_READ, MAP_PRIVATE, fp, 0);
  if (value == (void *)-1) {
    printf("Could not read file: %s\n", strerror(errno));
    return 0;
  }
}
