
# A difference between two objects. Assumes == override in object
# Stores both objects if different and flags is_diff = true
class Difference

  attr_accessor :diffs, :is_diff

  def initialize(table_name)
    @diffs = {}
    @is_diff = false
    @table_name = table_name
  end

  def test_diff(arg1, arg2, type)
    unless arg1 == arg2
      @diffs[type.to_sym] = [arg1, arg2]
      @is_diff = true
    end
  end
end