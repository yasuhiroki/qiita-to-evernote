module Qiita2Evernote
  Error = Struct.new(:item, :exception) do
    def out
      puts "- Error. Could not crete note #{item['title']}."
      puts "  - URL: #{item['url']}"
      puts exception.parameter if exception.respond_to?(:parameter)
      puts exception.message
    end
  end
end
