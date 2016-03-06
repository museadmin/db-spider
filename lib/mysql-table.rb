require_relative 'env'

# Encapsulate a Mysql Table
#
# @author Bradley Atkins
class MysqlTable

  attr_accessor :name, :fields, :keys, :constraints, :migrated, :diff

  def initialize(table_name)
    @name = table_name      # Table name
    @fields = {}            # Columns
    @keys = {}              # Column keys from desc table. TODO deprecate?
    @constraints = {}       # Table constraint
    @migrated = false
    @diff = MysqlDiff.new
  end

  # Compare self to another table
  # Key comparison controlled from env.rb
  #
  # @param table [MysqlTable] The table for comparison
  def ==(table)

    @diff.test_diff(self.name, table.name, 'table_name')
    @diff.test_diff(self.fields.size, table.fields.size, 'fields_size')

    @fields.values.each do |v|
      unless table.fields[v.name.to_sym].nil?
        @diff.test_diff(v.name, table.fields[v.name.to_sym].name, 'field_name')
        @diff.test_diff(v.type, table.fields[v.name.to_sym].type, 'field_type')
        @diff.test_diff(v.null, table.fields[v.name.to_sym].null, 'field_nullable')
        @diff.test_diff(v.default, table.fields[v.name.to_sym].default, 'field_default')
        @diff.test_diff(v.extra, table.fields[v.name.to_sym].extra, 'field_extra')

        if COMPARE_KEYS # Keys in field object, not table

           @diff.test_diff(self.keys.keys.size, table.keys.keys.size, 'number_of_keys') if COMPARE_KEY_COUNT

            if COMPARE_MUL_KEY
              if v.key == 'MUL' || table.fields[v.name.to_sym].key == 'MUL'
                @diff.test_diff(v.key, table.fields[v.name.to_sym].key, 'key')
              end
            end
            if COMPARE_UNI_KEY
              if v.key == 'UNI' || table.fields[v.name.to_sym].key == 'UNI'
                @diff.test_diff(v.key, table.fields[v.name.to_sym].key, 'key')
              end
            end
            if COMPARE_PRI_KEY
              if v.key == 'PRI' || table.fields[v.name.to_sym].key == 'PRI'
                @diff.test_diff(v.key, table.fields[v.name.to_sym].key, 'key')
              end
            end

        end
      end
    end

    # Compare constraints
    if COMPARE_CONSTRAINTS
      @diff.test_diff(self.constraints.size, table.constraints.size, 'number_of_constraints')

      @constraints.each do |k,c|
        unless table.constraints[k.to_sym].nil?
          @diff.test_diff(c.constraint_name, table.constraints[k.to_sym].constraint_name, 'constraint_name')
          @diff.test_diff(c.constraint_catalog, table.constraints[k.to_sym].constraint_catalog, 'constraint_catalog')
          @diff.test_diff(c.unique_constraint_catalog, table.constraints[k.to_sym].unique_constraint_catalog,
                          'unique_constraint_catalog')
          @diff.test_diff(c.match_option, table.constraints[k.to_sym].match_option, 'constraint_match_option')
          @diff.test_diff(c.delete_rule, table.constraints[k.to_sym].delete_rule, 'constraint_delete_rule')
          @diff.test_diff(c.table_name, table.constraints[k.to_sym].table_name, 'constraint_table_name')
          @diff.test_diff(c.referenced_table_name, table.constraints[k.to_sym].referenced_table_name, 'constraint_referenced_table_name')
        end
      end
    end
    return false if @diff.is_diff
    true
  end
end
