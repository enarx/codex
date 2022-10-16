package wasi;

public class Fibonacci {
    public static void main(String[] args) {
        int n = Integer.parseInt(args[0]);
        System.out.println(fib(n));
    }

    private static int fib(int n)
    {
        if (n <= 1)
            return n;
        return fib(n - 1) + fib(n - 2);
    }
}