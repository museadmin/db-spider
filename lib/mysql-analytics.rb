
require_relative 'env'

module MysqlAnalytics

  # Spider the databases listed in the config
  #
  # @param ini_data [Hash] Config settings from file
  # @author Bradley Atkins
  def spider_databases(ini_data)

    # Look up our rdbms
    case ini_data[:rdbms]['rdbms']
      when 'mysql'
        # Discovery for both databases listed in config
        @cxns.each do |k,db|
          # Tell db to create array of tables and record their names
          db.get_table_names
          # Discover all DB metadata for the tables just found
          db.spider
        end
      else
        raise "Unrecognised rdbms (#{ini_data[:rdbms]['rdbms']}) in config"
    end
  end

  # Analyse both DB's and create a diff for each mismatched table
  #
  # @param src_db [MysqlDatabase] The source database
  # @param tgt_db [MysqlDatabase] The target database
  def discover_diffs(src_db, tgt_db, db_diff)

    db_diff.locations.each do |k,v|
      # if src and tgt
      if src_db.has_table(k) && tgt_db.has_table(k)
        src_db.tables[k].map_diffs(tgt_db.tables[k], db_diff)
      end
    end
  end

end
