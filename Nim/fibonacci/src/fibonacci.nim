import std/os, std/parseutils, std/rdstdin, std/strformat

proc fib(n: int): int =
  case n:
    of 0, 1:
      n
    else:
      fib(n - 1) + fib(n - 2)

proc main =
  var args = commandLineParams()

  if args.len == 0:
    var line: string

    if not readLineFromStdin("Enter a non-negative number: ", line):
      echo ("Failed to read line")
      quit QuitFailure

    args.add(line)

  var index: int

  for arg in args:
    if arg.parseInt(index) == 0:
      echo fmt("Failed to parse number: {arg}")
      quit QuitFailure

    echo (fmt"Fibonacci sequence number at index {index} is {fib(index)}")

when isMainModule:
  main()
