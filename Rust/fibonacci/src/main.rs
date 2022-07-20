use std::io;

fn fib (n: u32) -> u32 {
    if n <= 0 {
        return 0;
    } else if n == 1 {
        return 1;
    }   fib(n - 1) + fib(n - 2)
 }

 fn main() {
    let mut nth = String::new();

    println!("Enter input: ");

    io::stdin()
        .read_line(&mut nth)
        .expect("Failed to read line");

    let nth: u32 = nth.trim().parse().expect("Please type a number!");

    println!("Fibonacci: {}", fib(nth));

}
