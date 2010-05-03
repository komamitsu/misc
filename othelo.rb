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
#    set(0, 0, :first)
#    set(2, 0, :first)
#    set(0, 1, :last)
#    set(1, 1, :last)
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
    dirs -= [0, 0]
    return nil unless
      dirs.inject(false) {|result, dir| 
        dx, dy = *dir
        result = true if rev(x, y, p, dx, dy)
        result
      }
    set(x, y, p)
  end

  def dump(level = 0)
    ppp = lambda do |p|
      return unless p
      p == :first ? 'o' : 'x'
    end
    bar = " #{Array.new(@length_x + 1, '+').join('-')}"
    puts_with_indent((0...@length_y).inject(' '){|a, n| "#{a} #{n}"}, level)
    puts_with_indent(bar, level)
    (0...@length_y).each do |y|
      puts_with_indent((0...@length_x).inject("#{y}|"){|a, x| "#{a}#{ppp.call(get(x, y)) || ' '}|"}, level)
      puts_with_indent(bar, level)
    end
  end

  def candidates(p)
    cs = []
    (0...@length_y).each do |y|
      (0...@length_x).each do |x|
        map = deep_copy
        cs << {:x => x, :y => y, :map => map} if map.get(x, y).nil? && map.put(x, y, p)
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

    children = 
      unless st[:empty].zero?
        cs = candidates(p)
        if cs.size > 0
          cs.map{|c| {:x => c[:x], :y => c[:y], :eval => c[:map].eval(next_pos)} }
        else
          cs = candidates(next_pos)
          if cs.size > 0
            cs.map{|c| {:x => c[:x], :y => c[:y], :eval => c[:map].eval(p)} }
          else
            st[:empty] = 0
            nil
          end
        end
      end

    score =
      if st[:empty].zero?
        diff = st[:first] - st[:last]
        diff /= diff.abs unless diff.zero?
        diff * max
      else
        nil
      end

    if children && children.size > 0
      score =
        case
        when children.all?{|c| c[:score] == 0} then 0
        when children.all?{|c| c[:score] == win} then win
        when children.all?{|c| c[:score] == lose} then lose
        when children.any?{|c| c[:position] == next_pos && c[:score] == win} then win
        when children.any?{|c| c[:position] == p && c[:score] == lose} then lose
        end 
    end

    {:map => deep_copy, :score => score, :position => next_pos, :children => children}
  end

  def dump_eval(e, level = 0)
    puts_with_indent('---------------------------------------------------', level)
    e[:map].dump(level)
    puts_with_indent("pos[#{e[:position]}] score[#{e[:score]}] children[", level)
    e[:children].each{|c| 
      puts_with_indent("x[#{c[:x]}] y[#{c[:y]}]", level + 1)
      dump_eval(c[:eval], level + 1)
    } if e[:children]
    puts_with_indent("]", level)
    puts_with_indent('---------------------------------------------------', level)
  end

  def deep_copy
    Marshal.load(Marshal.dump(self))
  end

  def puts_with_indent(s, level = 0)
    print ' ' * level * 2
    puts s
  end

  def next_pos(p)
    p == :first ? :last : :first
  end

  def finish?(p)
    st = status
    if st[:empty].zero? || (candidates(p).empty? && candidates(next_pos(p)).empty?)
      return st[:first] - st[:last]
    end
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
        return
      elsif get(x, y) == o
        rs << [x, y]
      else
        rs.each do |xx, yy|
          set(xx, yy, p)
        end
        return rs.size > 0
      end
    end
  end
end

map = Map.new(3, 3)
me = :first
opponent = map.next_pos(me)
finish = lambda do |p| 
  if result = map.finish?(p)
    puts 'finish!!!'
    case
    when result > 0 then puts 'you won'
    when result < 0 then puts 'you lost'
    when result = 0 then puts 'draw'
    end
    true
  end
end

map.dump
while l = gets do
  next unless l =~ /(\d+).*(\d+)/
  map.put($1.to_i, $2.to_i, me)
  map.dump
  break if finish.call(opponent)
  puts '----------- computer is thinking... --------------'
  tree = map.eval(opponent)
  candidate = 
    if me == :first
      tree[:children].min{|c| c[:eval][:score]}
    else
      tree[:children].max{|c| c[:eval][:score]}
    end
  map.put(candidate[:x], candidate[:y], opponent)
  map.dump
  break if finish.call(p)
end
  
# map = Map.new(3, 3)
# map.dump_eval(map.eval(:first))

# p map.put(1, 3, 0)
# map.dump
# pp map.eval(:last)
=begin
map = Map.new
p map.put(2, 4, 0)
p map.put(2, 3, 1)
p map.put(2, 2, 0)
p map.put(5, 4, 1)
map.dump
=end