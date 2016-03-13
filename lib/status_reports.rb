
# Handle writing status reports to screen
class StatusReports

  def initialize(resource_file)

    # Find the resource file
    pwd = File.expand_path File.dirname(__FILE__)

    begin
      @resource_file = File.new(File.expand_path("#{pwd}/../resources/#{resource_file}"), 'r')
      @resource_strings = IO.readlines @resource_file
    rescue Exception => e
      raise Exception("ERROR: Reading Resource file (#{e.message})")
    end

    def update(index)
      begin
        puts @resource_strings[index].sub(/\s*[\w']+\s+/, '')

        unless @log_file.nil?
          @logger.info @resource_strings[index].sub(/\s*[\w']+\s+/, '')
        end
      rescue Exception => e
        raise Exception("ERROR: Referencing Resource file (#{e.message})")
      end

    end

  end

end