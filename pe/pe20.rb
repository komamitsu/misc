def fact(n)
  1.upto(n).inject(1) {|a, i| a * i}
end

n = fact 100
p n.to_s.split(//).inject(0){|a, i| a + Integer(i)}
