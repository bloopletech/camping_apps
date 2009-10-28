class LoggedArray
  def initialize
    @arr = []
  end

  def inspect
    @arr.inspect
  end

  def method_missing(name, *args, &block)
    puts "In a LoggedArray \##{@arr.__id__}, calling method #{name} with #{args.inspect}, block_given? #{block_given?}"
    @arr.send(name, *args, &block)
  end
end