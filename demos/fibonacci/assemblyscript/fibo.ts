import "wasi";

export function fibo(n: i32): i32 {
  if (n == 0 || n == 1) return n;
  return fibo(n - 1) + fibo(n - 2);
}

let res = fibo(7);
console.log(res.toString());
