class Map
  def initialize
    @map = Array.new(8) { Array.new(8) }
    @map[3][3] = 0
    @map[3][4] = 1
    @map[4][3] = 1
    @map[4][4] = 0
  end

  def put(x, y, p)
    raise "invalid position" if over?(x, y)
    [-1, 0, 1].inject([]) {|a, i|
      [-1, 0, 1].each {|ii| a << [i, ii]}
      a
    }.each do |dir_x, dir_y|
      rev(x, y, p, dir_x, dir_y)
    end
    @map[y][x] = p
  end

  def print
    bar = ' |-+-+-+-+-+-+-+-|'
    puts (0..7).inject(' '){|a, n| "#{a} #{n}"}
    puts bar
    (0..7).each do |y|
      puts (0..7).inject("#{y}|"){|a, x| "#{a}#{@map[y][x] || ' '}|"}
      puts bar
    end
  end

  private
  def over?(x, y)
    x < 0 || y < 0 || x >= 8 || y >= 8
  end

  def rev(x, y, p, dir_x, dir_y)
    o = p == 0 ? 1 : 0
    rs = []
    loop do
      x += dir_x
      y += dir_y
      if over?(x, y) || @map[y][x].nil?
        return
      elsif @map[y][x] == o
        rs << [x, y]
      else
        rs.each do |x, y|
          @map[y][x] = p
        end
        return
      end
    end
  end
end

map = Map.new
map.put(2, 4, 0)
map.put(2, 3, 1)
map.put(2, 2, 0)
map.print
