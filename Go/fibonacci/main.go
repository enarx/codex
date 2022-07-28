package main

import (
	"fmt"
	"strconv"
	"os"
)

const DEFAULT_N int = 10

func FibonacciSequence(n int) int {
    if n <= 1 {
        return n
    }
    return FibonacciSequence(n-1) + FibonacciSequence(n-2)
}

func main(){
    n := DEFAULT_N
    
    if len(os.Args) > 1 {
    	n, _ = strconv.Atoi(os.Args[1])
    } else {
    	var input string
    	fmt.Print("Which Fibonacci index to find? ")
    	fmt.Scanln(&input)
		n, _ = strconv.Atoi(input)
    }
    
    if n < -1 {
		n = DEFAULT_N
	}

    fmt.Printf("Fibonacci sequence number at index %d is %d" , n , FibonacciSequence(n));
}
