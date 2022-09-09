use std::env::args;
use std::io::stdin;

fn fib(n: u32) -> u32 {
    match n {
        0 => 0,
        1 => 1,
        n => fib(n - 1) + fib(n - 2),
    }
}

fn main() {
    println!("Rust - Fibonacci sequence example");

    let mut args: Vec<_> = args().skip(1).collect();

    if args.is_empty() {
        println!("Enter a non-negative number:");
        let mut idx = String::new();
        stdin().read_line(&mut idx).expect("Failed to read line");
        args.push(idx);
    }

    for arg in args {
        let idx = arg.trim().parse().expect("Failed to parse number");
        println!("Fibonacci sequence number at index {} is {}", idx, fib(idx));
    }
}
