func fibonacci(n: Int) -> Int {
var a = 0
var b = 1
for _ in 0..<n {
let temp = a
a = b
b = temp + b
}
return a
}

print(fibonacci(n:7))
