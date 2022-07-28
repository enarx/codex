#include <iostream>
#include <cstdlib>
using namespace std;

unsigned int FibonacciSequence(unsigned int num) {
    if(num <= 1) {
        return num ;
    }
    return FibonacciSequence(num-1) + FibonacciSequence(num-2);
}

int main(int argc, char* argv[]){
	unsigned int n;
	if (argc > 1) {
		for(int i = 1; i < argc; i++) {
			n = atoi(argv[i]);
			cout << "Fibonacci sequence number at index " << n << " is " << FibonacciSequence(n) << endl;
		}
	} else {
		cout << "Which Fibonacci index to find? ";
		cout.flush();
		cin >> n;
		cout << "Fibonacci sequence number at index " << n << " is " << FibonacciSequence(n) << endl;
	}
}
