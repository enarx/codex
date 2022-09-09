using System;

namespace MyFirstWasiApp
{
    public class Program
    {

        public void fibonacci(ref int num){
            int a=1,b=0,temp;
            while(num >= 0){
                temp=a;
                a=a+b;
                b=temp;
                num--;
            }
            Console.WriteLine("Fibonacci Term is: "+b);
        }

        public static void Main(string[] args)
        {
            Program p = new Program();
            int num=10;
            p.fibonacci(ref num);
        }

    }
}
