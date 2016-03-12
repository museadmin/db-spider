require 'json'
require 'optparse'
require 'ostruct'
require_relative 'lib/env'
require_relative 'lib/mysql-analytics'
require_relative 'lib/mysql-constraint'
require_relative 'lib/db_difference'
require_relative 'lib/difference'
require_relative 'lib/mysql-db'
require_relative 'lib/mysql-field'
require_relative 'lib/mysql-select'
require_relative 'lib/mysql-table'
require_relative 'lib/utilities'

include Utils
include DbHelper
include MysqlAnalytics

# Parse the Args
options = OpenStruct.new
OptionParser.new do |opt|
  opt.on('-d', '--diff', 'Scan for diffs between source and target databases'
        ){options.diff = true}
  opt.on('-q', '--query', 'Generate SQL Queries for insert, update, select and delete for table -t'
        ){options.generate = true}
  opt.on('-s', '--spider SPIDER', 'Spider the databases <true|false>'
        ){|s| options.spider = s}
  opt.on('-t', '--table TABLE', 'Table to perform operation on. <All> for all tables'
        ){|t| options.table = t}
end.parse!

# Start

# get the ini file configuration settings
@ini_data = load_cfg

# Create the DB Connection farm
@cxns = create_cxns(@ini_data)

# Set source and destination DB
@db_src = @cxns[:db1]
@db_tgt = @cxns[:db2]
if @ini_data[:db2]['role'] == 'source'
  @db_src = @cxns[:db2]
  @db_tgt = @cxns[:db1]
end

# Spider the DB's
if options.spider.nil? || options.spider == 'true'
  spider_databases(@ini_data)
end

# Scan tables for @diffs
if options.diff
  # Object to hold all differences between databases
  @db_diff = DbDifference.new(@db_src.database, @db_tgt.database)
  # Map the location of all table elements
  @db_diff.locate_elements(@db_src, @db_tgt)

  # TODO Now we have all the mappings for the table elements
  # > analytics > table == > table.diff
  # Change to db_diff > table == > db_diff.diff
  discover_diffs(@db_src, @db_tgt, @db_diff)
end



# Execute the options passed in by the user
if options.generate
  # Generate the SQL commands for a table
  raise 'This option requires a -t <table> and -d <db-schema>' unless options.table && options.db_schema

  # Names are set so go get them
  @cxns.each do |k,v|
    if v.database == options.db_schema
      @this_db = @cxns[k]
      raise "Failed to find database table (#{options.table})" unless @this_db.tables[options.table.to_sym]
      break
    end
  end

  # Generate the select statement for all fields in table
  puts "Default select for table #{options.table}:"
  puts @this_db.build_default_select(options.table) + ';'

end

puts

