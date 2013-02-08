class Coordinate < HyperObject
  def initialize *dimensions
    @dimensions = dimensions.flatten
  end

  def x
    @dimensions.first
  end
  alias_method :height, :x
  alias_method :row, :x

  def y
    @dimensions[1]
  end
  alias_method :width, :y
  alias_method :col, :y

  def z
    @dimensions[2]
  end
  alias_method :depth, :z
  alias_method :layer, :z
end
