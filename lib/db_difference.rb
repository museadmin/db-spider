
DF_SRC = 0
DF_TGT = 1
DF_FKEY = 2
DF_INDEX = 3
DF_FLD = 4

# Encapsulate the differences between two databases
# Assumes no RDBMS
# Unlike the DB objects, stores only the differences between
# src and tgt db's.
class DbDifference

  attr_accessor :locations, :diffs

  # Constructor
  #
  # @param src_db [MysqlDatabase] The source database
  # @param tgt_db [MysqlDatabase] The target database
  def initialize(src_db = '', tgt_db = '')
    @src_db = src_db
    @tgt_db = tgt_db
    @locations = {} # [src,tgt,fk,k,fld]
    @diffs = {}
  end

  # Print a report of all table diffs
  def print_table_diffs
    self.diffs.each do |k,v|
      puts "[#{k}]"
      v.each do |d|
        printf "\t%s\n", "name: #{d.name}"
        printf "\t\t%s\n", "type: #{d.type}"
        printf "\t\t%s\n", "vsrc: #{d.vsrc}"
        printf "\t\t%s\n", "vtgt: #{d.vtgt}"
      end
    end
  end

  # Capture all differences between two databases
  #
  # @param src_db [MysqlDatabase] The source database
  # @param tgt_db [MysqlDatabase] The target database
  def locate_elements(src_db, tgt_db)
    get_table_locations(src_db, tgt_db)
    get_field_locations(src_db, tgt_db)
    get_fk_locations(src_db, tgt_db)
    get_key_locations(src_db, tgt_db)
  end

  # Capture where indexed keys are located
  #
  # @param src_db [MysqlDatabase] The source database
  # @param tgt_db [MysqlDatabase] The target database
  private
  def get_key_locations(src_db, tgt_db)
    # For each table
    @locations.keys.each do |t|
      # Create a unique sorted and merged list of keys from both dbs
      # Use tmp hash to get sort behaviour
      keys = {}
      if @locations[t.to_sym][DF_SRC]
        src_db.tables[t.to_sym].keys.keys.each do |k|
          keys[k] = nil
        end
      end
      if @locations[t.to_sym][DF_TGT]
        tgt_db.tables[t.to_sym].keys.keys.each do |k|
          keys[k] = nil
        end
      end
      fkn = Hash[keys.sort]

      # For each index in this table
      indexes = {}
      fkn.keys.each do |k|
        # Map if fk exists in both tables
        fd = Array[false, false]
        unless src_db.tables[t].nil?
          fd[DF_SRC] = true if src_db.tables[t].has_key(k)
        end
        unless tgt_db.tables[t].nil?
          fd[DF_TGT] = true if tgt_db.tables[t].has_key(k)
        end
        indexes[k] = fd
      end
      @locations[t][DF_INDEX] = indexes
    end
  end

  # Capture where table constraints are located
  #
  # @param src_db [MysqlDatabase] The source database
  # @param tgt_db [MysqlDatabase] The target database
  private
  def get_fk_locations(src_db, tgt_db)
    # For each table
    @locations.keys.each do |t|
      # Create a unique sorted and merged list of foreign key names from both dbs
      # Use tmp hash to get sort behaviour
      fk = {}
      if @locations[t.to_sym][DF_SRC]
        #src_db.tables[t.to_sym].constraints.keys.each do |k|
        src_db.tables[t.to_sym].constraints.keys.each do |k|
          fk[k] = nil
        end
      end
      if @locations[t.to_sym][DF_TGT]
        tgt_db.tables[t.to_sym].constraints.keys.each do |k|
          fk[k] = nil
        end
      end
      fkn = Hash[fk.sort]

      # For each foreign key in this table
      tfk = {}
      fkn.keys.each do |k|
        # Map if fk exists in both tables
        fd = Array[false, false]
        unless src_db.tables[t].nil?
          fd[DF_SRC] = true if src_db.tables[t].has_constraint(k)
        end
        unless tgt_db.tables[t].nil?
          fd[DF_TGT] = true if tgt_db.tables[t].has_constraint(k)
        end
        tfk[k] = fd
      end
      @locations[t][DF_FKEY] = tfk
    end
  end
  # Capture where table fields are located
  #
  # @param src_db [MysqlDatabase] The source database
  # @param tgt_db [MysqlDatabase] The target database
  private
  def get_field_locations(src_db, tgt_db)

    # For each table
    @locations.keys.each do |t|
      # Create a unique sorted and merged list of field names from both dbs
      # Use tmp hash to get sort behaviour
      f = {}
      if @locations[t.to_sym][DF_SRC]
        src_db.tables[t.to_sym].fields.keys.each do |k|
          f[k] = nil
        end
      end
      if @locations[t.to_sym][DF_TGT]
        tgt_db.tables[t.to_sym].fields.keys.each do |k|
          f[k] = nil
        end
      end
      fn = Hash[f.sort]

      # For each key in this table
      tfd = {}
      fn.keys.each do |k|
        # Map if field exists in both tables
        fd = Array[false, false]
        unless src_db.tables[t].nil?
          fd[DF_SRC] = true if src_db.tables[t].has_field(k)
        end
        unless tgt_db.tables[t].nil?
          fd[DF_TGT] = true if tgt_db.tables[t].has_field(k)
        end
        tfd[k] = fd
      end
      @locations[t][DF_FLD] = tfd
    end
  end
  # Capture where the tables are located.
  #
  # @param src_db [MysqlDatabase] The source database
  # @param tgt_db [MysqlDatabase] The target database
  private
  def get_table_locations(src_db, tgt_db)

    # Create a unique sorted and merged list of table names from both dbs
    # Use tmp hash to get sort behaviour
    l = {}
    src_db.tables.keys.each do |k|
      l[k] = nil
    end
    tgt_db.tables.keys.each do |k|
      l[k] = nil
    end
    @locations = Hash[l.sort]

    # Capture location of each table e.g. Both, src only or tgt only
    @locations.keys.each do |k|
      td = Array[false, false, nil, nil, nil]
      if src_db.has_table(k)
        td[DF_SRC] = true
      end
      if tgt_db.has_table(k)
        td[DF_TGT] = true
      end
      @locations[k.to_sym] = td
    end

  end
end