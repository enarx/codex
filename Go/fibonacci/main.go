package main

import (
	"bufio"
	"flag"
	"fmt"
	"log"
	"os"
	"strconv"
)

func init() {
	log.SetFlags(0)
}

func fib(n uint64) uint64 {
	if n <= 1 {
		return n
	}
	return fib(n-1) + fib(n-2)
}

func main() {
	flag.Parse()

	args := flag.Args()
	if len(args) == 0 {
		fmt.Println("Enter a non-negative number:")
		sc := bufio.NewScanner(os.Stdin)
		sc.Scan()
		b, err := sc.Bytes(), sc.Err()
		if err != nil {
			log.Fatal("Failed to read stdin: %s", err)
		}
		args = []string{string(b)}
	}

	for _, arg := range args {
		n, err := strconv.ParseUint(arg, 10, 64)
		if err != nil {
			log.Fatalf("Failed to parse number: %s", err)
		}
		fmt.Printf("Fibonacci sequence number at index %d is %d\n", n, fib(n))
	}
}
