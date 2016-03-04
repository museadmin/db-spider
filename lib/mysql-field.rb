require_relative 'env'

# Encapsulate a Mysql Field
class MysqlField

  attr_accessor :name, :type, :null, :key, :default, :extra

  def initialize(field_name = '', type = '', null = 'YES', key = nil, default = nil, extra = '')
    @name = field_name
    @type = type
    @null = null
    @key = key
    @default = default
    @extra = extra
  end
end
