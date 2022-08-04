#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

unsigned long fib(unsigned long i) {
  if (i <= 1) {
    return i;
  }
  return fib(i - 1) + fib(i - 2);
}

int main(int argc, char *argv[]) {
  printf("C - Fibonacci sequence example\n");
  if (argc <= 1) {
    unsigned long n;
    printf("Enter a non-negative number:\n");
    if (scanf("%lu", &n) != 1) {
      fprintf(stderr, "Failed to read number from stdin\n");
      exit(1);
    }
    printf("Fibonacci sequence number at index %lu is %lu\n", n, fib(n));
  } else {
    for (unsigned int i = 1; i < argc; i++) {
      errno = 0;
      unsigned long n = strtoul(argv[i], NULL, 10);
      if (errno != 0) {
        fprintf(stderr, "Failed to parse argument into a number: %s\n",
                strerror(errno));
        exit(1);
      }
      printf("Fibonacci sequence number at index %lu is %lu\n", n, fib(n));
    }
  }
}
