#include <stdio.h>
#include <stdlib.h>

#define DEFAULT_N 10

int FibonacciSequence(int num) {
    if(num <= 1) {
        return num ;
    }
    return FibonacciSequence(num-1) + FibonacciSequence(num-2);
}

int main(int argc, char* argv[]){
	int n = DEFAULT_N;
    if (argc > 1) {
    	n = atoi(argv[1]);
    } else {
    	printf("Which Fibonacci index to find? ");
    	int matched = scanf("%d", &n);
    	if (matched < 1) {
    		n = DEFAULT_N;
    	}
    }

    if (n < -1) {
		n = DEFAULT_N;
	}

    printf("Fibonacci sequence number at index %d is %d" , n , FibonacciSequence(n));
}
