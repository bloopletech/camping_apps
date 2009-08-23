class LinearRegression
  attr_accessor :slope, :offset

  def initialize dx, dy=nil
    @size = dx.size
    dy,dx = dx,axis() unless dy  # make 2D if given 1D
    raise "arguments not same length!" unless @size == dy.size
    sxx = sxy = sx = sy = 0
    dx.zip(dy).each do |x,y|
      sxy += x*y
      sxx += x*x
      sx  += x
      sy  += y
    end
    if @size == 1
      @slope = 1
      @offset = dy.first
    else
      @slope = ( @size * sxy - sx*sy ) / ( @size * sxx - sx * sx )
      @offset = (sy - @slope*sx) / @size
    end
  end

  def fit
    return axis.map{|data| predict(data) }
  end

  def predict( x )
    y = @slope * x + @offset
  end

  def axis
    (0...@size).to_a
  end
end