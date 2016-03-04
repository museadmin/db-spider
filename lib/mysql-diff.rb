
# A table delta. Holds all data required to resolve a db delta
# DB Schema is assumed
class MysqlDiff

  attr_accessor :deltas, :is_delta

  def initialize
    @deltas = {}
    @is_delta = false
  end

  def test_diff(arg1, arg2, type)
    unless arg1 == arg2
      @deltas[type.to_sym] = [arg1, arg2]
      @is_delta = true
    end
  end
end