out = File.new("NamesList2.txt", "w")
lines = IO.readlines("NamesList.txt")
lines.each do |l|
  out << l if l[0..1] =~ /^[0-9A-F]+/
end
out.close