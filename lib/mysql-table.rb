require_relative 'env'

# Encapsulate a Mysql Table
#
# @author Bradley Atkins
class MysqlTable

  attr_accessor :table_name, :fields, :keys, :constraints, :migrated, :diff

  def initialize(table_name)
    @table_name = table_name      # Table name
    @fields = {}            # Columns
    @keys = {}              # Column keys from desc table.
    @constraints = {}       # Table constraint
    @migrated = false
    @diffs = {}
  end

  def test_diff(arg1, arg2, name, field)
    unless arg1 == arg2
      diff = Difference.new
      diff.obj1 = arg1
      diff.obj2 = arg2
      diff.field = field
      diff.is_diff = true
      @diffs[name] = diff
    end
  end

  # Compare self to another table
  # Key comparison controlled from env.rb
  #
  # @param table [MysqlTable] The table for comparison
  def map_diffs(table, db_diff)

    test_diff(self.table_name, table.table_name, 'table_name', nil)
    test_diff(self.fields.size, table.fields.size, 'fields_size', nil)

    @fields.values.each do |v|
      unless table.fields[v.name.to_sym].nil?
        test_diff(v.name, table.fields[v.name.to_sym].name, 'field_name', v.name)
        test_diff(v.type, table.fields[v.name.to_sym].type, 'field_type', v.name)
        test_diff(v.null, table.fields[v.name.to_sym].null, 'field_nullable', v.name)
        test_diff(v.default, table.fields[v.name.to_sym].default, 'field_default', v.name)
        test_diff(v.extra, table.fields[v.name.to_sym].extra, 'field_extra', v.name)

        if COMPARE_KEYS # Keys in field object, not table

           test_diff(self.keys.keys.size, table.keys.keys.size, 'number_of_keys', v.name) if COMPARE_KEY_COUNT

            if COMPARE_MUL_KEY
              if v.key == 'MUL' || table.fields[v.name.to_sym].key == 'MUL'
                test_diff(v.key.type, table.fields[v.name.to_sym].key.type, 'key', v.name)
              end
            end
            if COMPARE_UNI_KEY
              if v.key == 'UNI' || table.fields[v.name.to_sym].key == 'UNI'
                test_diff(v.key.type, table.fields[v.name.to_sym].key.type, 'key', v.name)
              end
            end
            if COMPARE_PRI_KEY
              if v.key == 'PRI' || table.fields[v.name.to_sym].key == 'PRI'
                test_diff(v.key.type, table.fields[v.name.to_sym].key.type, 'key', v.name)
              end
            end

        end
      end
    end

    # Compare constraints
    if COMPARE_CONSTRAINTS
      test_diff(self.constraints.size, table.constraints.size, 'number_of_constraints', nil)

      @constraints.each do |k,c|
        unless table.constraints[k.to_sym].nil?
          name = c.constraint_name
          test_diff(c.constraint_name, table.constraints[k.to_sym].constraint_name, 'constraint_name', name)
          test_diff(c.constraint_catalog, table.constraints[k.to_sym].constraint_catalog, 'constraint_catalog', name)
          test_diff(c.unique_constraint_catalog, table.constraints[k.to_sym].unique_constraint_catalog, 'unique_constraint_catalog', name)
          test_diff(c.match_option, table.constraints[k.to_sym].match_option, 'constraint_match_option', name)
          test_diff(c.delete_rule, table.constraints[k.to_sym].delete_rule, 'constraint_delete_rule', name)
          test_diff(c.table_name, table.constraints[k.to_sym].table_name, 'constraint_table_name', name)
          test_diff(c.referenced_table_name, table.constraints[k.to_sym].referenced_table_name, 'constraint_referenced_table_name', name)
        end
      end
    end
    db_diff.diffs[@table_name] = @diffs unless @diffs.empty?
  end

  # Confirm if table has index on field
  #
  # @param name [String] Name of index
  # @return [Boolean] True if index found
  def has_key(name)
    @keys.keys.each do |k|
      return true if k == name
    end
    false
  end
  # Confirm if table has field
  #
  # @param name [String] Name of field
  # @return [Boolean] True if field found
  def has_field(name)
    @fields.keys.each do |k|
      return true if k == name
    end
    false
  end

  # Confirm if table has constraint
  #
  # @param name [String] Name of constraint
  # @return [Boolean] True if constraint found
  def has_constraint(name)
    @constraints.keys.each do |k|
      return true if k == name
    end
    false
  end

end
