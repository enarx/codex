def FibonacciSequence( n )
  return  n  if ( 0..1 ).include? n
  ( FibonacciSequence( n - 1 ) + FibonacciSequence( n - 2 ) )
end

if ARGV.length > 0
  ARGV.each { |arg|
	n = arg.to_i
    puts "Fibonacci sequence number at index #{n} is #{FibonacciSequence(n)}"
  }
else
  puts "Which Fibonacci index to find? "
  n = ARGF.gets.to_i
  puts "Fibonacci sequence number at index #{n} is #{FibonacciSequence(n)}"
end
