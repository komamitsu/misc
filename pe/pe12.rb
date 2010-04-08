def dnum n
  ds = {}

  i = 2
  loop do
    if n % i == 0
      k = i.to_s
      ds[k] ||= 0
      ds[k] += 1
      n = n / i
    else
      i += 1
    end

    break if n < i
  end

  ds.keys.inject(1) {|acc, k| acc * (ds[k] + 1) }
end

def t
  i = 1
  loop do
    n = i * (i + 1) /2
#    p n
    yield n
    i += 1
  end
end


t do |n|
  if dnum(n) >= 500
    puts "========== #{n} ============"
    exit
  end
end
