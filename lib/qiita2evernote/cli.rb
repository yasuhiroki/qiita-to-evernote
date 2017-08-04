require 'thor'
require 'dotenv'

require_relative './client'
require_relative './error'

class Qiita2Evernote::Cli < Thor

  desc "init", "initialize"
  def init
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

  desc "stocks", "Show qiita stocks list"
  def stocks
    items = qiita.stock_items(ENV["QIITA_ID"])

    items.each do |item|
      p item["title"]
    end
  end

  desc "notebooks", "Show evernote notebooks list"
  def notebooks
    # Get your note store object
    note_store = evernote.evernote_client

    # List all of the notebooks in the user's account
    notebooks = note_store.listNotebooks(ENV["EVERNOTE_TOKEN"])
    puts "Found #{notebooks.size} notebooks:"
    notebooks.sort_by{|n| n.name}.each do |notebook|
      puts "  * #{notebook.name}"
    end
  end

  desc "q2e", "Add qiita stoks to evernote notebook"
  def q2e

    # Get your note store object
    note_store_client = evernote.evernote_client

    # Get your qiita stock items
    items = qiita.stock_items(ENV["QIITA_ID"])

    # Get your default notebook object
    notebooks = note_store_client.listNotebooks(ENV["EVERNOTE_TOKEN"])
    default_note_book = notebooks.find{|n| n.name == ENV["EVERNOTE_DEFAULT_NOTEBOOK"]}

    error = []

    items.each do |item|
      begin
        if evernote.same_title_note_exist?(item['title'])
          puts "#{item['title']} is exist. skip."
          next
        end

        note = evernote.create_note(
          item['title'], evernote.to_enml_from(item['rendered_body']), default_note_book.guid)
        evernote.upload_evernote(note)
      rescue => e
        error << Qiita2Evernote::Error.new(item, e)
        next
      end
      puts "Created #{item['title']} in evernote."
      sleep 0.2
    end

    error.each do |e|
      e.out
    end
  end

  private
    def qiita
      @qiita ||= Qiita2Evernote::Client::Qiita.new(ENV["QIITA_TOKEN"])
    end
    def evernote
      @evernote ||= Qiita2Evernote::Client::Evernote.new(ENV["EVERNOTE_TOKEN"], ENV['EVERNOTE_NOTE_STORE'])
    end
end

