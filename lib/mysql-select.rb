require_relative 'env'

# Encapsulate a Mysql Select Statement against a table
#
# @author Bradley Atkins
class MysqlSelectStatement

  # select fields from table
  def initialize(table_name, use_alias = true)
    @use_alias = use_alias
    @table_name = table_name
    @fields = []
    @joins = []
    @aliases = []
    @select = nil
  end

  def add_fields_to_select(fields)
    fields.each do |k,v|
      self.add_field_to_select(v.name)
    end
  end

  def add_field_to_select(field)
    @fields.push(field)
  end

  def build_statement
    sql = 'select'
    @fields.each do |f|
      sql = sql << " #{f},"
    end
    sql[0...-1] << " from #{@table_name}"
  end
end