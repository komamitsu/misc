require 'pp'

def walk(route)
  route.each_with_index do |row, iy|
    row.each_with_index do |point, ix|
      if iy == 0
        point[1] = point[0]
      else
        v = route[iy - 1][ix] ? route[iy - 1][ix][1] : 0
        d = ix == 0 ? 0 : route[iy - 1][ix - 1][1]
        point[1] = point[0] + [v, d].max
      end
    end
  end
  p route[route.size - 1].inject(0){|a, r| [a, r[1]].max}
end

def make_route(text)
  text.inject([]) do |route, line|
    points = line.split(/\s+/)
    route << points.map{|p| [p.to_i, 0]}
  end
end

route_text = <<EOS
75
95 64
17 47 82
18 35 87 10
20 04 82 47 65
19 01 23 75 03 34
88 02 77 73 07 63 67
99 65 04 28 06 16 70 92
41 41 26 56 83 40 80 70 33
41 48 72 33 47 32 37 16 94 29
53 71 44 65 25 43 91 52 97 51 14
70 11 33 28 77 73 17 78 39 68 17 57
91 71 52 38 17 14 91 43 58 50 27 29 48
63 66 04 68 89 53 67 30 73 16 69 87 40 31
04 62 98 27 23 09 70 98 73 93 38 53 60 04 23
EOS

walk(make_route(route_text))
