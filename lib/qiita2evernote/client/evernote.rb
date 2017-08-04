require 'h2e'
require 'evernote-thrift'

class Qiita2Evernote::Client::Evernote

  def initialize(evernote_token, evernote_note_store)
    @evernote_token = evernote_token
    @evernote_note_store = evernote_note_store
    @converter = H2E::Converter.new
    @converter.html_base_url = "https://qiita.com"
  end

  def evernote_client
    return @note_store if @note_store

    note_storeTransport = Thrift::HTTPClientTransport.new(@evernote_note_store)
    note_storeProtocol = Thrift::BinaryProtocol.new(note_storeTransport)
    @note_store = Evernote::EDAM::NoteStore::NoteStore::Client.new(note_storeProtocol)
    return @note_store
  end

  def to_enml_from(html)
    @converter.from(html)
  end

  def create_note(title, content, notebook_guid)
    Evernote::EDAM::Type::Note.new({
      :title => title,
      :notebookGuid => notebook_guid,
      :content => content,
    })
  end

  def same_title_note_exist?(title)
    filter = Evernote::EDAM::NoteStore::NoteFilter.new
    filter.words = 'intitle:"' + title + '"'

    result_spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new
    result_spec.includeTitle = true

    found_notes = @note_store.findNotesMetadata(@evernote_token, filter, 0, 10, result_spec).notes

    found_notes.any?{|note| note.title == title}
  end

  def upload_evernote(note)
    @note_store.createNote(@evernote_token, note)
  end

end


