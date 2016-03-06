
# A table diff. Holds all data required to resolve a db diff
# DB Schema is assumed
class MysqlDiff

  attr_accessor :diffs, :is_diff

  def initialize
    @diffs = {}
    @is_diff = false
  end

  def test_diff(arg1, arg2, type)
    unless arg1 == arg2
      @diffs[type.to_sym] = [arg1, arg2]
      @is_diff = true
    end
  end
end