require_relative 'env'

# Encapsulate a Mysql Table
#
# @author Bradley Atkins
class MysqlTable

  attr_accessor :name, :fields, :keys, :constraints, :migrated, :delta

  def initialize(table_name)
    @name = table_name      # Table name
    @fields = {}            # Columns
    @keys = {}              # Column keys from desc table. TODO deprecate?
    @constraints = {}       # Table constraint
    @migrated = false
    @delta = MysqlDelta.new
  end

  # Compare self to another table
  # Key comparison controlled from env.rb
  #
  # @param table [MysqlTable] The table for comparison
  def ==(table)

    @delta.test_delta(self.name, table.name, 'table_name')
    @delta.test_delta(self.fields.size, table.fields.size, 'fields_size')

    @fields.values.each do |v|
      unless table.fields[v.name.to_sym].nil?
        @delta.test_delta(v.name, table.fields[v.name.to_sym].name, 'field_name')
        @delta.test_delta(v.type, table.fields[v.name.to_sym].type, 'field_type')
        @delta.test_delta(v.null, table.fields[v.name.to_sym].null, 'field_nullable')
        @delta.test_delta(v.default, table.fields[v.name.to_sym].default, 'field_default')
        @delta.test_delta(v.extra, table.fields[v.name.to_sym].extra, 'field_extra')

        if COMPARE_KEYS # Keys in field object, not table

           @delta.test_delta(self.keys.keys.size, table.keys.keys.size, 'number_of_keys') if COMPARE_KEY_COUNT

            if COMPARE_MUL_KEY
              if v.key == 'MUL' || table.fields[v.name.to_sym].key == 'MUL'
                @delta.test_delta(v.key, table.fields[v.name.to_sym].key, 'key')
              end
            end
            if COMPARE_UNI_KEY
              if v.key == 'UNI' || table.fields[v.name.to_sym].key == 'UNI'
                @delta.test_delta(v.key, table.fields[v.name.to_sym].key, 'key')
              end
            end
            if COMPARE_PRI_KEY
              if v.key == 'PRI' || table.fields[v.name.to_sym].key == 'PRI'
                @delta.test_delta(v.key, table.fields[v.name.to_sym].key, 'key')
              end
            end

        end
      end
    end

    # Compare constraints
    if COMPARE_CONSTRAINTS
      @delta.test_delta(self.constraints.size, table.constraints.size, 'number_of_constraints')

      @constraints.each do |k,c|
        unless table.constraints[k.to_sym].nil?
          @delta.test_delta(c.constraint_name, table.constraints[k.to_sym].constraint_name, 'constraint_name')
          @delta.test_delta(c.constraint_catalog, table.constraints[k.to_sym].constraint_catalog, 'constraint_catalog')
          @delta.test_delta(c.unique_constraint_catalog, table.constraints[k.to_sym].unique_constraint_catalog,
                            'unique_constraint_catalog')
          @delta.test_delta(c.match_option, table.constraints[k.to_sym].match_option, 'constraint_match_option')
          @delta.test_delta(c.delete_rule, table.constraints[k.to_sym].delete_rule, 'constraint_delete_rule')
          @delta.test_delta(c.table_name, table.constraints[k.to_sym].table_name, 'constraint_table_name')
          @delta.test_delta(c.referenced_table_name, table.constraints[k.to_sym].referenced_table_name, 'constraint_referenced_table_name')
        end
      end
    end
    return false if @delta.is_delta
    true
  end
end
