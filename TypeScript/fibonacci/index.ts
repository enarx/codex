function fibonacci(num: number) {
    var a: number = 1;
    var b: number = 0;
    var temp: number;
    while (num >= 0) {
        temp = a;
        a = a + b;
        b = temp;
        num--;
    }
    console.log("Fibonacci Term is:", b);
}

