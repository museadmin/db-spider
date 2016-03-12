
# A difference between two objects. Assumes == override in object
# Stores both objects if different and flags is_diff = true
class Difference

  attr_accessor :name, :obj1, :obj2, :field, :is_diff

  def initialize
    @obj1 = nil
    @obj2 = nil
    @field = nil
    @is_diff = false
  end

end