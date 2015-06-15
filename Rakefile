require 'rake'
require 'dotenv'
require 'qiita'
require 'qiita-markdown'
require 'evernote-thrift'

require_relative './html-to-enml'

Dotenv.load

def qiita_client # {{{
  @client ||= Qiita::Client.new(access_token: ENV["QIITA_TOKEN"])
end
# }}}

def qiita_stock_items(client) # {{{
  return @items if @items

  id = ENV["QIITA_ID"]

  per_page = 100
  stocks_first = client.list_user_stocks(id, per_page: per_page)
  stocks_page_num = stocks_first.headers["Total-Count"].to_i / per_page + 1

  @stocks = {
    1 => stocks_first.body
  }
  (2..stocks_page_num).each do |i|
    @stocks[i] = client.list_user_stocks(id, per_page: per_page, page: i).body
  end
  @items = @stocks.map { |_, items| items}.flatten

  return @items
end
# }}}

def qiita_markdown # {{{
  @processor ||= Qiita::Markdown::Processor.new
end
# }}}

def evernote_client # {{{
  return @noteStore if @noteStore

  noteStoreUrl = ENV["EVERNOTE_NOTE_STORE"]
  noteStoreTransport = Thrift::HTTPClientTransport.new(noteStoreUrl)
  noteStoreProtocol = Thrift::BinaryProtocol.new(noteStoreTransport)
  @noteStore = Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)
  return @noteStore
end
# }}}

desc "Initialize dotenv" # {{{
task :init do
  require 'io/console'

  puts "What is your qiita API token?"
  puts "  - If you have not API token, let's get it from [https://qiita.com/settings/applications]."
  print "your id: "
  qiita_id = STDIN.gets.chop || ""
  qiita_id = ENV["QIITA_ID"] if qiita_id.empty?
  print "token: "
  qiita_token = STDIN.gets.chop || ""
  qiita_token = ENV["QIITA_TOKEN"] if qiita_token.empty?
  puts ""

  puts "What is your evernote token?"
  puts "  - If you have not token, let's get it from [https://www.evernote.com/api/DeveloperToken.action]."
  print "token: "
  evernote_token = STDIN.gets.chop || ""
  evernote_token = ENV["EVERNOTE_TOKEN"] if evernote_token.empty?
  print "note store: "
  evernote_note_store = STDIN.gets.chop || ""
  evernote_note_store = ENV["EVERNOTE_NOTE_STORE"] if evernote_note_store.empty?
  puts ""
  puts "Evernote default notebook"
  print "default notebook: "
  evernote_defulat_notebook = STDIN.gets.chop || ""
  evernote_defulat_notebook = ENV["EVERNOTE_DEFAULT_NOTEBOOK"] if evernote_defulat_notebook.empty?

  File.open(".env", 'w') do |f|
    f.write("QIITA_ID=\"#{qiita_id}\"\n") unless qiita_id.empty?
    f.write("QIITA_TOKEN=\"#{qiita_token}\"\n") unless qiita_token.empty?
    f.write("EVERNOTE_TOKEN=\"#{evernote_token}\"\n") unless evernote_token.empty?
    f.write("EVERNOTE_NOTE_STORE=\"#{evernote_note_store}\"\n") unless evernote_note_store.empty?
    f.write("EVERNOTE_DEFAULT_NOTEBOOK=\"#{evernote_defulat_notebook}\"\n") unless evernote_defulat_notebook.empty?
  end
end
# }}}

desc "Show qiita stack item list" # {{{
task "qiita:stocks" do

  items = qiita_stock_items(qiita_client)

  items.each do |item|
    p item["title"]
  end
end
# }}}

desc "Show evernote notebooks list" # {{{
task "evernote:notebooks" do

  # Get your note store object
  note_store = evernote_client

  # List all of the notebooks in the user's account
  notebooks = note_store.listNotebooks(ENV["EVERNOTE_TOKEN"])
  puts "Found #{notebooks.size} notebooks:"
  notebooks.sort_by{|n| n.name}.each do |notebook|
    puts "  * #{notebook.name}"
  end

end
# }}}

desc "Add qiita stoks to evernote notebook" # {{{
task "qiita:stock:to:evernote" do

  # Get your note store object
  note_store_client = evernote_client

  # Get your qiita stock items
  items = qiita_stock_items(qiita_client)

  # Get your default notebook object
  notebooks = note_store_client.listNotebooks(ENV["EVERNOTE_TOKEN"])
  default_note_book = notebooks.find{|n| n.name == ENV["EVERNOTE_DEFAULT_NOTEBOOK"]}

  # List all of the notebooks in the user's account
  ENML_HEADER = <<HEADER
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
HEADER

  @converter = QiitaToEvernote.new

  def convert_to_evernote_note(qiita_item, notebook_guid)
    content = "#{ENML_HEADER}"
    content << "<en-note>"
    content << @converter.to_enml_from(qiita_item["rendered_body"]).to_s
    #content << qiita_markdown.call(qiita_item["body"])[:output].to_s
    content << "</en-note>"

    Evernote::EDAM::Type::Note.new({
      :title => qiita_item["title"],
      :notebookGuid => notebook_guid,
      :content => content
    })
  end

  items.each do |item|
    filter = Evernote::EDAM::NoteStore::NoteFilter.new
    filter.words = item['title']

    result_spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new
    result_spec.includeTitle = true

    found_notes = note_store_client.findNotesMetadata(ENV["EVERNOTE_TOKEN"], filter, 0, 1, result_spec).notes
    if found_notes.any?{|note| note.title == item['title']}
      puts "#{item['title']} is exist. skip."
      next
    end

    note = convert_to_evernote_note(item, default_note_book.guid)
    begin
      note_store_client.createNote(ENV["EVERNOTE_TOKEN"], note)
    rescue Evernote::EDAM::Error::EDAMUserException => e
      puts "- Error. Could not crete note #{item['title']}."
      puts e.parameter
      puts e.message
      next
    end
    puts "Created #{item['title']} in evernote."
    sleep 1.0
  end
end
# }}}

