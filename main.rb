require 'json'
require 'optparse'
require 'ostruct'
require 'highline/import'
require 'logger'

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
require_relative 'lib/menu_handler'
require_relative 'lib/status_reports'
require_relative 'lib/reporting'
require_relative 'lib/list_manager'

include Utils
include DbHelper
include MysqlAnalytics
@list_manager = ListManager.new

# Start
$status = StatusReports.new('en.lang')
@reporter = Reporting.new

# get the ini file configuration settings
$status.update(0)
@ini_data = load_cfg

# Create the DB Connection farm
$status.update(1)
@cxns = create_cxns(@ini_data)

# Set source and destination DB
@db_src = @cxns[:db1]
@db_tgt = @cxns[:db2]
if @ini_data[:db2]['role'] == 'source'
  @db_src = @cxns[:db2]
  @db_tgt = @cxns[:db1]
end

# Always Spider the DB's
$status.update(2)
spider_databases(@ini_data)
@db_diff = DbDifference.new(@db_src.database, @db_tgt.database)
# Map the location of all table elements
$status.update(3)
@db_diff.locate_elements(@db_src, @db_tgt)
# Map the differences between all tables that exist
# in source and target DB's that differ
$status.update(4)
discover_diffs(@db_src, @db_tgt, @db_diff)

#puts @list_manager.get_list_item(get_sorted_list_of_tables(@db_src, @db_tgt))
# puts get_sorted_list_of_tables(@db_src, @db_tgt)
# exit

# Main Menu Driven Loop
begin
  menu = MenuHandler.new(@reporter, @db_diff, @db_src, @db_tgt)
  loop do
    menu.main_menu
  end
end

# TODO Generate SQL for migration
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

