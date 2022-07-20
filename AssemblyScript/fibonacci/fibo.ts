import "wasi";
import { Console } from "as-wasi";

export function fibo (n: i32): i32 {
if(n==1 || n==0){
  return n;
}
else{
  return fibo(n-1) + fibo(n-2);
}
}

let a: i32 = fibo(7);
Console.log(a.toString());
