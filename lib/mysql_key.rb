
# Encapsulate a key on a table field
class MysqlKey
  attr_accessor :type

  def initialize(type)
    @type = type
  end

  def ==(type)
    return true if @type == type
    false
  end
end