func fib(n: UInt) -> UInt {
	if n <= 1 {
		return n
	}

	return fib(n: n-1) + fib(n: n-2)
}

let arguments = CommandLine.arguments

var n:UInt
if (arguments.count > 1) {
	for i in 1...arguments.count-1 {
		if let n = UInt(arguments[i]) {
			print("Fibonacci sequence number at index \(n) is \(fib(n: n))")
		} else {
			print("Failed to parse argument into a number: \(arguments[i])\n")
		}
	}
} else {
	print("Enter a non-negative number:")
	if let line = readLine() {
		if let n = UInt(line) {
			print("Fibonacci sequence number at index \(n) is \(fib(n: n))")
		} else {
			print("Could not convert \(line) to integer.\n")	
		}
	} else {
		print("Could not read user input.\n")	
	}
}
