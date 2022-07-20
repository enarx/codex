#include <stdio.h>

int FibonacciSequence(int num) {
    if(num <= 1) {
        return num ;
    }
    return FibonacciSequence(num-1) + FibonacciSequence(num-2);
}
int main(){
    printf("Enter the Number\n");
    int n ;
    scanf("%d",&n);

    printf("Fibonacci Sequence term at %d is %d " , n , FibonacciSequence(n));
}
