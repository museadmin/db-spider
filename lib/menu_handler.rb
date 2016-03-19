require_relative 'mysql-analytics'
require_relative 'list_manager'
include MysqlAnalytics


# Handle the menus for the application
class MenuHandler

  def initialize(reporting, db_diff, db_src, db_tgt)
    @reporting = reporting
    @db_diff = db_diff
    @db_src = db_src
    @db_tgt = db_tgt
    @list_manager = ListManager.new
  end

  def main_menu
    begin
      loop do
        system 'clear'
        choose do |menu|
          menu.prompt = 'Select an Action'
          menu.choice(:Reports){reports_menu}
          menu.choice(:Quit){exit(0)}
        end
      end
    end
  end

  def reports_menu

    begin
      loop do
        choose do |menu|
          system 'clear'
          menu.prompt = 'Select a Report'

          menu.choice(:Table_diff){
            report = '/tmp/table_diffs.txt'
            $stdout = File.new(report , 'w' )
            $stdout.sync = true
            @reporting.table_diffs(@db_diff)
            $stdout = STDOUT
            msg = $status.get_resource_string(5)
            print_msg_and_clear("#{msg} #{report}")
            gets
          }

          menu.choice(:Table_detail){
            sorted_list = get_sorted_list_of_tables(@db_src, @db_tgt)
            print_msg('Enter the name of a table')
            table_name = @list_manager.autocomplete_list_item(sorted_list)

            # TODO method to write out tabel details

          }

          menu.choice(:Quit){return}
        end
      end
    end
  end
end
