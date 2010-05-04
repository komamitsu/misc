require 'pp'

class Map
  MAX = 99999999
  MIN = -MAX

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
    return nil if over?(x, y)
    return nil if get(x, y)

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
    puts_with_indent((0...@length_x).inject(' '){|a, n| "#{a} #{n}"}, level)
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

  def eval(p, max = MIN, min = MAX, passed = false)
    st = status
    next_pos = next_pos(p)

    children = 
      if st[:empty].zero?
        []
      else
        cs = candidates(p)
        if cs.empty?
          if passed
            st[:empty] = 0
          else
            cs << {:map => deep_copy}
            passed = true
          end
        end

        # f       4          6          ?     eval(f, 6, 4)
        #      |  |  |    |  |  |    |  |  |
        # l    4  5  6    6  7  8    5  x  x  eval(l, MIN, MAX)
        # 
        unless st[:empty].zero?
          child_evals =
            cs.inject(:max => MIN, :min => MAX, :evals => [], :cut => false) do |a, c| 
              child_eval = c[:map].eval(next_pos, a[:max], a[:min], passed)
              if (c[:position] == :first && child_eval[:score] < max ) || (c[:position] == :last && child_eval[:score] > min)
                a[:cut] = true
              end

              a[:evals] << {:x => c[:x], :y => c[:y], :eval => child_eval} unless a[:cut]
              a[:max] = [a[:max], (c[:score] || 0)].max
              a[:min] = [a[:min], (c[:score] || 0)].min
              a
            end
          child_evals[:evals]
        end
      end

    score =
      if st[:empty].zero?
        diff = st[:first] - st[:last]
        diff /= diff.abs unless diff.zero?
        diff * MAX
      else
        0
      end

    if children && children.size > 0
      scores = children.map{|c| c[:eval][:score]}
      score = p == :first ? scores.max : scores.min
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

map = Map.new(4, 4)
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
loop do
  puts '----------- enter "x y" or "pass" --------------'
  l = gets
  unless l.strip == 'pass'
    next unless l =~ /(\d+).*(\d+)/
    next unless map.put($1.to_i, $2.to_i, me)
    map.dump
    break if finish.call(opponent)
  end
  puts '----------- computer is thinking... --------------'
  tree = map.eval(opponent)
  candidate = 
    if me == :first
      tree[:children].min_by{|c| c[:eval][:score]}
    else
      tree[:children].max_by{|c| c[:eval][:score]}
    end
  next if candidate[:x].nil? && candidate[:y].nil?
  map.put(candidate[:x], candidate[:y], opponent)
  map.dump
  break if finish.call(me)
end

