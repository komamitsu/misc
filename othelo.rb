require 'pp'

class Map
  def initialize(len_x = 8, len_y = 8)
    @length_x = len_x
    @length_y = len_y
    @map = Array.new(@length_y) { Array.new(@length_x) }
    set(@length_y / 2 - 1, @length_x / 2 - 1, :first)
    set(@length_y / 2 - 1, @length_x / 2,     :last)
    set(@length_y / 2,     @length_x / 2 - 1, :last)
    set(@length_y / 2,     @length_x / 2,     :first)
  end

  def get(x, y)
    @map[y][x]
  end

  def set(x, y, p)
    @map[y][x] = p
  end

  def put(x, y, p)
    raise "invalid position" if over?(x, y)

    dirs = []
    dir_unit = [-1, 0, 1]
    dir_unit.each {|dy| dir_unit.each{|dx| dirs << [dx, dy]}}
    return false unless dirs.any?{|dx, dy| rev(x, y, p, dx, dy)}
    set(x, y, p)
  end

  def print
    ppp = lambda do |p|
      return unless p
      p == :first ? 'o' : 'x'
    end
    bar = " #{Array.new(@length_x + 1, '+').join('-')}"
    puts (0...@length_y).inject(' '){|a, n| "#{a} #{n}"}
    puts bar
    (0...@length_y).each do |y|
      puts (0...@length_x).inject("#{y}|"){|a, x| "#{a}#{ppp.call(get(x, y)) || ' '}|"}
      puts bar
    end
  end

  def candidates(p)
    cs = []
    (0...@length_y).each do |y|
      (0...@length_x).each do |x|
        map = Marshal.load(Marshal.dump(self))
        cs << map if map.get(x, y).nil? && map.put(x, y, p)
      end
    end
    cs
  end

  def status
    st = {:first => 0, :last => 0, :empty => 0}
    (0...@length_y).each do |y|
      (0...@length_x).each do |x|
        case get(x, y)
        when :first then st[:first] += 1
        when :last then st[:last] += 1
        when nil then st[:empty] += 1
        else raise 'invalid value'
        end
      end
    end
    st
  end

  def eval(p)
    max = 1000
    st = status
    win = :first ? max : -max
    lose = -win
    next_pos = next_pos(p)

    score =
      if st[:empty].zero?
        diff = st[:first] - st[:last]
        diff /= diff.abs unless diff.zero?
        diff * max
      else
        nil
      end

    children = 
      unless st[:empty].zero?
        cs = candidates(p)
        if cs.size > 0
          cs.map{|c| c.eval(next_pos)}
        else
          cs = candidates(next_pos)
          cs.map{|c| c.eval(p)}
        end
      end

    if children && children.size > 0
      score = win if children.all?{|c| c[:score] == win}
      score = lose if children.all?{|c| c[:score] == lose}
      score = win if children.any?{|c| c[:position] == next_pos && c[:score] == win}
      score = lose if children.any?{|c| c[:position] == p && c[:score] == lose}
    end

    {:map => @map.clone, :score => score, :position => p, :children => children}
  end

  private
  def over?(x, y)
    x < 0 || y < 0 || x >= @length_x || y >= @length_y
  end

  def rev(x, y, p, dir_x, dir_y)
    o = next_pos(p)
    rs = []
    loop do
      x += dir_x
      y += dir_y
      if over?(x, y) || get(x, y).nil?
        return false
      elsif get(x, y) == o
        rs << [x, y]
      else
        rs.each do |x, y|
          set(x, y, p)
        end
        return rs.size > 0
      end
    end
  end

  def next_pos(p)
    p == :first ? :last : :first
  end
end

map = Map.new(4, 3)
# p map.put(1, 3, 0)
map.print
pp map.eval(:last)
=begin
map = Map.new
p map.put(2, 4, 0)
p map.put(2, 3, 1)
p map.put(2, 2, 0)
p map.put(5, 4, 1)
map.print
=end
