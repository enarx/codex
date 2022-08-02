#include <cstdlib>
#include <iostream>
#include <string.h>

using namespace std;

unsigned long fib(unsigned long i) {
  if (i <= 1) {
    return i;
  }
  return fib(i - 1) + fib(i - 2);
}

int main(int argc, char *argv[]) {
  if (argc <= 1) {
    unsigned long n;
    cout << "Enter a non-negative number:" << endl;
    cin >> n;
    cout << "Fibonacci sequence number at index " << n << " is " << fib(n)
         << endl;
  } else {
    for (unsigned int i = 1; i < argc; i++) {
      errno = 0;
      unsigned long n = strtoul(argv[i], NULL, 10);
      if (errno != 0) {
        cerr << "Failed to parse argument into a number: " << strerror(errno)
             << endl;
        exit(1);
      }
      cout << "Fibonacci sequence number at index " << n << " is " << fib(n)
           << endl;
    }
  }
}
