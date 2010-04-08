=begin
LEN = 20
c = 0
q = []
q.push [0, 0]
loop do
  x, y = q.pop
  break if x.nil? && y.nil?
  if x == LEN && y == LEN
    c += 1
  else
    q.push [x + 1, y] if x < LEN
    q.push [x, y + 1] if y < LEN
  end
end
p c
=end

len = 20 + 1
map = Array.new(len) {Array.new(len) {0}}
len.times{|i| map[0][i] = 1}
len.times{|i| map[i][0] = 1}
(1...len).each{|y|
  (1...len).each{|x| map[y][x] = map[y - 1][x] + map[y][x - 1]}
}
p map[len - 1][len - 1]
