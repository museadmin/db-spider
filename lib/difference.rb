
# A difference between two objects. Assumes == override in object
# Stores both objects if different and flags is_diff = true
class Difference

  attr_accessor :name, :vsrc, :vtgt, :type

  def initialize
    @vsrc = nil
    @vtgt = nil
    @name = nil
    @type = nil
  end

end