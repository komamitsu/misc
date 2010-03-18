map = [
  "###############",
  "#S            #",
  "# ##### ##### #",
  "# #         # #",
  "# # ######### #",
  "# #         # #",
  "# ######### # #",
  "#         # ###",
  "###########   #",
  "#           # #",
  "# #############",
  "#            G#",
  "###############",
]

class Pos
  attr_accessor :y, :x

  def initialize(y, x)
    @y = y
    @x = x
  end

  def ==(other)
    @y == other.y && @x == other.x
  end

  def self.dist(a, b)
    Math.sqrt((b.x - a.x) ** 2 + (b.y - a.y) ** 2)
  end
end

class Route
  def initialize(start, goal)
    @start = start
    @goal  = goal
    @route = []

    push(@start, nil)
  end

  def push(pos, last_pos)
    dist ||= Pos.dist(@goal, pos)
    @route << [pos, dist, last_pos]
    @route = @route.sort_by{|r| r[1]}
  end

  def pop
    @route.first[0]
  end

  def walked?(pos)
    find(pos)
  end

  def surrounded(pos)
    find(pos)[1] = 9999999
    sort
  end

  def dump
    l = []
    pos = @goal
    loop do
      l << pos
      r = find(pos)
      break unless r[2]
      pos = r[2]
    end
    l
  end

  private
  def find(pos)
    @route.detect{|r| r[0] == pos}
  end

  def sort
    @route = @route.sort_by{|r| r[1]}
  end
end

start = Pos.new(1, 1)
goal  = Pos.new(11, 13)
route = Route.new(start, goal)

loop do
  break if (pos = route.pop) == goal
  walkable = 
    [[-1, 0], [0, 1], [1, 0], [0, -1]].inject(0) do |result, mov|
      pos_next = Pos.new(pos.y + mov[0], pos.x + mov[1])
      c = map[pos_next.y][pos_next.x]
      unless c == ?# || route.walked?(pos_next)
        route.push pos_next, pos
        result += 1
      end
      result
    end

  route.surrounded(pos) if walkable.zero?
end

route.dump.each do |pos|
  map[pos.y][pos.x] = '*'
end

map.each do |line|
  puts line
end

