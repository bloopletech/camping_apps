out = File.new(ARGV[0], "w")
ARGV[1].to_i.upto(ARGV[2].to_i) do |x|
  out << "#{x.to_s(16).upcase}\t#{ARGV[3]}-#{x.to_s(16).upcase}\n"
end
out.close