dev = !ENV.key?("CAMPING_ENV") || ENV["CAMPING_ENV"] == "development"
prod = !dev

desc "Starts the server using rackup for development"
task :start_rackup_development do
  system("rackup -p 8005 -E none init/camping.ru")
end

desc "Starts the server using rackup for production"
task :start_rackup_production do
  system("rackup -p 8004 -E none -P #{File.dirname(__FILE__)}/tmp/pids/rack.pid init/camping.ru &")
end

desc "Starts the server using rackup for the current environment"
task :start_rackup do
  Rake::Task[dev ? "start_rackup_development" : "start_rackup_production"].invoke
end

task :sr => :start_rackup

task :stop_rackup_production do
  system("kill `cat tmp/pids/rack.pid`") if File.exists?("tmp/pids/rack.pid")
  sleep(5)
  system("kill -9 `cat tmp/pids/rack.pid`") if File.exists?("tmp/pids/rack.pid")
end

task :restart_rackup_production => [:stop_rackup_production, :start_rackup_production] #test
  

desc "Starts the server using camping's builtin server"
task :start_camping do
  #bad example with ARGV
  system("scripts/camping.rb #{ARGV[1]}")
end

task :sc => :start_camping



desc "Clear caches"
task :clear_caches do
  Dir.glob("./*/public/cache/*").each { |dir| FileUtils.rm(dir) }
end
  