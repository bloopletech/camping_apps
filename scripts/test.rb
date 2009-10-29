if __FILE__ == $0
  require 'net/http'
  require 'benchmark'
  sites = %w(countr ajas blog concise crowdcount job kc m i things unicode watchlist wikiwatcher)
  if ARGV[0] == 'local'
    sites.map! { |s| "http://l:8005/#{s}" } 
  else
    sites.map! { |s| "http://#{s}.bloople.net/" }
  end

  sites.each do |s|
    puts s
    puts Benchmark.measure {
      puts "#{s} failed" if Net::HTTP.get_response(URI.parse(s)).code != '200'
    }
  end
end