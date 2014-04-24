def format_mode(mode)
  3.times.map { |i|
    value = mode / (010 ** i) % 010

    execute = (value & 1 << 0) > 0
    read = (value & 1 << 2) > 0
    write = (value & 1 << 1) > 0

    [
      read ? "r" : "-",
      write ? "w" : "-",
      execute ? "x" : "-",
    ].join
  }.reverse.join
end

Dir["*"].each do |file|
  puts "#{ format_mode(File.stat(file).mode) } #{ file }"
end
