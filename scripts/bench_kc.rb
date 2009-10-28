if __FILE__ == $0
  require 'net/http'
  require 'benchmark'
  1.upto(100) do |n|
    puts "Attempt #{n}:"
    puts Benchmark.measure {
      puts "failed" if Net::HTTP.get_response(URI.parse("http://kc.bloople.net/")).code != '200'
    }
  end
end