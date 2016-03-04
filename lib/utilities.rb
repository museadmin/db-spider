require 'inifile'

module Utils

  def load_cfg

    # Get the config set label
    base_cfg = ENV['MOT_API_CFG']

    # Find the config file
    pwd = File.expand_path File.dirname(__FILE__)
    cfg_file = File.expand_path("#{pwd}/#{base_cfg}.yml")

    # Load the config
    IniFile.load(cfg_file)

  end

end