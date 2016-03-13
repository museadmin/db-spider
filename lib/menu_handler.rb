

# Handle the menus for the application
class MenuHandler

  def initialize(reporting, db_diff)
    @reporting = reporting
    @db_diff = db_diff
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
          menu.choice(:Table_diff){@reporting.table_diffs(@db_diff)}
          menu.choice(:Quit){return}
        end
      end
    end
  end
end
