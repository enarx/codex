#include <stdio.h>
#include <stdlib.h>

unsigned int FibonacciSequence(unsigned int num) {
    if(num <= 1) {
        return num ;
    }
    return FibonacciSequence(num-1) + FibonacciSequence(num-2);
}

int main(int argc, char* argv[]){
	unsigned int n;
    if (argc > 1) {
    	int i;
    	for(i = 1; i < argc; i++) {
    		n = atoi(argv[i]);
    		printf("Fibonacci sequence number at index %d is %d\n" , n , FibonacciSequence(n));
    	}
    } else {
    	printf("Which Fibonacci index to find? ");
    	int matched = scanf("%u", &n);
    	if (matched < 1) {
    		n = 10;
    	}
    	printf("Fibonacci sequence number at index %d is %d\n" , n , FibonacciSequence(n));
    }
}
