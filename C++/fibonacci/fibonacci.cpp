// Simple Program to calculate Fibonacci Sequence of an integer input
#include <iostream>
using namespace std;
int FibonacciSequence(int num) {
    if(num <= 1) {
        return num ;
    }
    return FibonacciSequence(num-1) + FibonacciSequence(num-2);
}
int main(){
    cout << "Enter the Number" << endl;
    int n ;
    cin  >> n ;

    cout << "Fibonacci Sequence term at " << n << "  " << "is " << FibonacciSequence(n) << endl;
}
