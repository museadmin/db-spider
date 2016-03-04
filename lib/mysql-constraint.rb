
# Express a Mysql Field Constraint
class MysqlConstraint

  attr_accessor :constraint_catalog, :constraint_schema, :constraint_name, :unique_constraint_catalog,
                :unique_constraint_schema, :unique_constraint_name, :match_option,
                :update_rule, :delete_rule,:table_name, :column_name, :referenced_table_name,
                :referenced_column_name
  # Constructor
  def initialize
    @constraint_catalog = nil
    @constraint_schema = nil
    @constraint_name = nil
    @unique_constraint_catalog = nil
    @unique_constraint_schema = nil
    @unique_constraint_name = nil
    @match_option = nil
    @update_rule = nil
    @delete_rule = nil
    @table_name = nil
    @column_name = nil
    @referenced_table_name = nil
    @referenced_column_name = nil
  end
end

