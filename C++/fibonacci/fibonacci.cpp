#include <iostream>
#include <cstdlib>
using namespace std;

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
		cout << "Which Fibonacci index to find? ";
		cout.flush();
		cin >> n;
	}

	if (n < -1) {
		n = DEFAULT_N;
	}

    cout << "Fibonacci sequence number at index " << n << " is " << FibonacciSequence(n) << endl;
}
