def FibonacciSequence( n )
  return  n  if ( 0..1 ).include? n
  ( FibonacciSequence( n - 1 ) + FibonacciSequence( n - 2 ) )
end

DEFAULT = 10

n = DEFAULT

if ARGV.length > 0
  n = ARGV[0].to_i
else
  puts "Which Fibonacci index to find? "
  n = ARGF.gets.to_i
end

if n < -1
  n = DEFAULT
end

puts "Fibonacci sequence number at index #{n} is #{FibonacciSequence(n)}"
