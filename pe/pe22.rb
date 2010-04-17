p ARGF.read.split(/,/).
  map{|s| s.gsub(/"/, '')}.
  sort_by{|s| s}.
  inject([1, 0]){|a, name|
    index = a[0]; total = a[1]
    sum = 0
    name.each_byte{|i| sum += (i - ?A + 1)}
#    puts "index: %d, total: %d, name: %s, sum: %d" % [index, total, name, sum]
    [index + 1, total + (sum * index)]
  }

