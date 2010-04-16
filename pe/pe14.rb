r = {}
2.upto(1000000) do |n|
  c = 1
  i = n
  until i == 1 do
    if r[i.to_s]
      c += r[i.to_s]
      break
    end
    
    if i % 2 == 0
      i /= 2
    else
      i = 3 * i + 1
    end
    c += 1
  end 
  r[n.to_s] = c
end

# 2 -> 1
# 3 -> 10 -> 5 -> 16 -> 8 -> 4 -> 2 -> 1
max =
  r.inject(['', 0]) do |acc, u|
    acc = u if acc[1] < u[1]
    acc
  end
p max
