func FibonacciSequence(n: Int) -> Int {
	if n <= 1 {
		return n
	}

	return FibonacciSequence(n: n-1) + FibonacciSequence(n: n-2)
}

let default_n = 10

var n = default_n

let arguments = CommandLine.arguments

if (arguments.count > 1) {
    n = Int(arguments[1]) ?? default_n
} else {
	print("Which Fibonacci index to find? ")
	if let line = readLine() {
		n = Int(line) ?? default_n
	}
}

if n < -1 {
	n = default_n
}


print("Fibonacci sequence number at index \(n) is \(FibonacciSequence(n: n))")
