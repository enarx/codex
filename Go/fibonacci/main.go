package main

import (
	"fmt"
	"strconv"
	"os"
)

func FibonacciSequence(n uint64) uint64 {
    if n <= 1 {
        return n
    }
    return FibonacciSequence(n-1) + FibonacciSequence(n-2)
}

func main(){
    if len(os.Args) > 1 {
    	for _, arg := range os.Args[1:] {
    		n, err := strconv.ParseUint(arg, 10, 64)
    		if err != nil {
				fmt.Fprintf(os.Stderr, "%s\n", err)
				continue
			}
    		fmt.Printf("Fibonacci sequence number at index %d is %d\n" , n , FibonacciSequence(n));
    	}
    } else {
    	var input string
    	fmt.Print("Which Fibonacci index to find? ")
    	fmt.Scanln(&input)
		n, err := strconv.ParseUint(input, 10, 64)
		if err != nil {
			fmt.Fprintf(os.Stderr, "%s\n", err)
			os.Exit(-1)
		}
		fmt.Printf("Fibonacci sequence number at index %d is %d\n" , n , FibonacciSequence(n));
    }
}
