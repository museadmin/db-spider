require 'inifile'

# Helper module for miscellaneous tasks
module Utils

  def load_cfg

    begin
      # Get the config set label
      base_cfg = ENV['MOT_API_CFG']
      base_cfg = 'config' if base_cfg.nil? || base_cfg == 'localhost'

      # Find the config file
      pwd = File.expand_path File.dirname(__FILE__)
      cfg_file = File.expand_path("#{pwd}/#{base_cfg}.yml")

      # Load the config
      IniFile.load(cfg_file)

    rescue Exception => e
      puts "ERROR: Loading ini file (#{e.message})"
      exit(1)
    end

  end

  def print_msg(msg)
    puts '=========================================='
    puts msg
    puts '=========================================='
  end

  def print_msg_and_clear(msg)
    system 'clear'
    puts '=========================================='
    puts msg
    puts '=========================================='
  end

end