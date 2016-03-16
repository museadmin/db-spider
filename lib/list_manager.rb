require 'io/console/size'

# Methods for managing lists
class ListManager

  def get_list_item(list)

    word = ''

    while(char = $stdin.getch) != "\r"

      word += char unless char == "\t"
      short_list = list.select{|subset| subset =~ /^#{word}/}

      if char == "\t"
        string_end = short_list.first[word.length..-1]
        word = short_list.first.to_s
        print string_end
      else
        print char
      end
    end

    short_list.first unless short_list.first.nil?
  end
end