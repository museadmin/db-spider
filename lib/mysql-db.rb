require 'mysql2'

require_relative 'env'

class TriggerStruct < Struct.new(:trigger, :negation, :action)
end

# Encapsulates methods for accessing the MOT Mysql Databases
#
# @author Bradley Atkins
class MysqlDatabase

  attr_reader :host, :username, :password, :database, :port, :schema_version, :tables

  # New instance. Read ini data and connect
  #
  # @param ini_data [Hash] Hash of items from ini file
  def initialize(ini_data, db)

    @host = ini_data[db]['host']
    @username = ini_data[db]['username']
    @password = ini_data[db]['password']
    @database = ini_data[db]['database']
    @port = ini_data[db]['port']
    @schema_version = ini_data[db]['schema_version']
    @connection = nil
    @tables = {}
    connect
  end

  # Build a default select query for a table in this database
  #
  # @param table_name [String] Name of the table
  # @author Bradley Atkins
  def build_default_select(table_name)

    raise "Table not found #{table_name}" unless self.has_table(table_name)
    table = tables[table_name.to_sym]
    select = MysqlSelectStatement.new(table_name)

    # Test for constraints. If none then happy days, easy task
    if table.constraints.empty?
      raise "Table (#{table_name}) has no columns!" if table.fields.nil?
      # Pass each field to the select object and then ask for the statement
      select.add_fields_to_select(table.fields)
      select.build_statement
    else
      # Table has constraints

    end
  end



  # Spider the database and retrieve the metadata for each table
  # Storing it all in the tables hash
  def spider

    @tables.each do |k,t|

      begin

        # Use desc table to get the name, type, nullable, key, default,extra
        rs = self.query_db("desc #{t.name}")
        rs.each(:as => :array) do |td|
          f = MysqlField.new
          f.name = td[FIELD]
          f.type = td[TYPE]
          f.null = td[NULL]
          f.key = td[KEY]
          f.default = td[DEFAULT]
          f.extra = td[EXTRA]

          unless td[KEY].empty?
            t.keys[f.name.to_sym] = f.key
          end

          # Push the field into the fields array in the table
          t.fields[f.name.to_sym] = f
        end

        # Now use create table to get the constraints
        sql = "select * from information_schema.referential_constraints where
              constraint_schema = '#{@database}' and TABLE_NAME = '#{t.name}'"
        rs = self.query_db(sql)

        if rs.count
          rs.each(:as => :array) do |td|
            c = MysqlConstraint.new
            # Create a new constraint
            c.constraint_catalog = td[CONSTRAINT_CATALOG]
            c.constraint_schema = td[CONSTRAINT_SCHEMA]
            c.constraint_name = td[CONSTRAINT_NAME]
            c.unique_constraint_name = td[UNIQUE_CONSTRAINT_CATALOG]
            c.unique_constraint_schema = td[UNIQUE_CONSTRAINT_SCHEMA]
            c.unique_constraint_name = td[UNIQUE_CONSTRAINT_NAME]
            c.match_option = td[MATCH_OPTION]
            c.update_rule = td[UPDATE_RULE]
            c.delete_rule = td[DELETE_RULE]
            c.table_name = td[TABLE_NAME]
            c.referenced_table_name = td[REFERENCED_TABLE_NAME]
            # Get the referenced table's column
            sql = "select COLUMN_NAME, REFERENCED_COLUMN_NAME from information_schema.key_column_usage
                  where referenced_table_name = '#{td[REFERENCED_TABLE_NAME]}' and constraint_schema
                  = '#{@database}' and TABLE_NAME = '#{t.name}'"
            c.referenced_column_name = self.query_db(sql).first['REFERENCED_COLUMN_NAME']
            c.column_name = self.query_db(sql).first['COLUMN_NAME']
            # Push to table hash
            t.constraints[c.constraint_name.to_sym] = c
          end
        end

      rescue => e
        raise "Error querying DB #{e.class}: #{e.message}"
      end
    end
  end

  # Get all the tables for the db into the array of table objects. Initializing with table name
  def get_table_names

    rs = self.query_db('show tables')

    rs.each(:as => :array) do |t|
      @tables[t[0].to_sym] = MysqlTable.new(t[0])
    end

    raise "Failed to recover table names from (#{@name})" if @tables.empty?
  end

  # Connect to the database using the parameters set in the constructor
  #
  def connect
    begin
      Mysql2::Client.default_query_options[:connect_flags] |= Mysql2::Client::MULTI_STATEMENTS
      @connection = Mysql2::Client.new(:host => @host, :username => @username, :password => @password,
                                       :database => @database, :port => @port)
    rescue Mysql2::Error => e
      raise "DB connection failed (#{e.errno} - #{e.message})"
    end
  end

  # Run a query against the database
  #
  # @param query [String] The sql query as a string
  def query_db(query)
    begin
      @connection.abandon_results!
      @connection.query("#{query.strip}")
    rescue Mysql2::Error => e
      raise "Query failed (#{query}). Error - (#{e.errno} - #{e.message})"
    end

  end

  # Run a query in a sql file. Assumes one query on one line
  #
  # @param sql_file [String] Fully qualified path to file
  # @param params [Array] Variable list of parameters for sql cmd
  def query_db_from_file(sql_file, *params)
    begin

      # Read in the sql file
      query = nil
      File.foreach(sql_file) do |line|
        query = "#{query} #{line.strip}"
      end

      # add any parameters passed in
      params.each do |p|
        p == 'null' ? query = query.sub('?', "#{p}") : query = query.sub('?', "'#{p}'")
      end

      # run the query
      @connection.query("#{query}")

    rescue Mysql2::Error => e
      raise "Query failed (#{query}): Error - (#{e.errno} - #{e.message})"
    rescue => e
      raise "Error running query file (#{sql_file}): Error - (#{e.errno} - #{e.message})"
    end
  end

  # Test if the database has a specific table
  #
  # @param table_name [String] Name of the table
  # @return [Boolean] True if table exists
  def has_table(table_name)
    return true if @tables[table_name.to_sym]
    false
  end

end

# Database Helper Methods
#
# @author Bradley Atkins
module DbHelper

  # Create a hash of connections to each database listed in the config
  #
  # @param ini_data [Hash] Hash of data from config file
  # @return [MotDatabase] Hash of database connectors
  def create_cxns(ini_data)
    c = Hash.new

    case ini_data[:rdbms]['rdbms']
      when 'mysql'
        (1..ini_data[:databases]['count']).each do |i|
          c.merge!({"db#{i}".to_sym => MysqlDatabase.new(ini_data, "db#{i}".to_sym)})
        end
      else
        raise "Unrecognised rdbms #{ini_data[:rdbms]['rdbms']} in config"
    end
    c
  end

end
