f = File.new("NamesList2.txt", "r")
c = f.read
f.close

f = File.new("NamesList4.txt", "w")
f << c.gsub(/^.*CJK UNIFIED IDEOGRAPH.*$/, '').gsub(/\n+/, "\n")
f.close
