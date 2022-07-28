from functools import cache
import sys

@cache
def fib(n):
    if n <= 0:
        return 0
    if n == 1:
        return 1
    else:
        return fib(n - 1) + fib(n - 2)

args = sys.argv[1:]

if len(args) == 0:
    print("Please pass one or more numbers as arguments to the program")
else:
    for arg in args:
        idx = int(arg)
        print(f"Fibonacci sequence number at index {idx} is {fib(idx)}")
