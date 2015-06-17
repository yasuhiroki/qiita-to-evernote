require 'oga'

class QiitaToEvernote

  ENML_PROHIBITED_ATTRIBUTES = [
    "id", "class", "onclick", "ondblclick", "accesskey",
    "data", "dynsrc", "tabindex", "data-lang", "data-conversation"
  ]

  ENML_HEADER = <<HEADER
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
HEADER

  def initialize(evernote_token, evernote_note_store) # {{{
    @evernote_token = evernote_token
    @evernote_note_store = evernote_note_store
  end
  # }}}

  def evernote_client # {{{
    return @note_store if @note_store

    note_storeTransport = Thrift::HTTPClientTransport.new(@evernote_note_store)
    note_storeProtocol = Thrift::BinaryProtocol.new(note_storeTransport)
    @note_store = Evernote::EDAM::NoteStore::NoteStore::Client.new(note_storeProtocol)
    return @note_store
  end
  # }}}

  def to_enml_from(html) # {{{
    content = "#{ENML_HEADER}"
    content << "<en-note>"
    content << remove_attr(Oga.parse_html(html)).to_xml.to_s
    content << "</en-note>"
    return content
  end
  # }}}

  def create_note(title, content, notebook_guid) # {{{
    Evernote::EDAM::Type::Note.new({
      :title => title,
      :notebookGuid => notebook_guid,
      :content => content,
    })
  end
  # }}}

  def same_title_note_exist?(title) # {{{
    filter = Evernote::EDAM::NoteStore::NoteFilter.new
    filter.words = title

    result_spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new
    result_spec.includeTitle = true

    found_notes = @note_store.findNotesMetadata(@evernote_token, filter, 0, 10, result_spec).notes

    found_notes.any?{|note| note.title == title}
  end
  # }}}

  def upload_evernote(note)# {{{
    @note_store.createNote(@evernote_token, note)
  end
# }}}

  private #{{{
    def remove_attr(doc) # {{{
      if doc.respond_to?(:children)
        doc.children.each do |doc_c|
          remove_attr(doc_c)
        end
      end
      if doc.respond_to?(:attribute)
        ENML_PROHIBITED_ATTRIBUTES.each do |attr|
          doc.unset(attr) if doc.attribute(attr)
        end
        if doc.name == "a"
          href = doc.attribute("href").value
          if href =~ %r(^/.+)
            doc.set("href", "https://qiita.com#{href}")
          elsif (href =~ %r(^(http|https)://.+)).nil?
            doc.set("href", "https://qiita.com/#{href}")
          end
        end
      end
      return doc
    end
    # }}}
    def escape_filter_word(word) # {{{
      if doc.respond_to?(:children)
        doc.children.each do |doc_c|
          remove_attr(doc_c)
        end
      end
      if doc.respond_to?(:attribute)
        ENML_PROHIBITED_ATTRIBUTES.each do |attr|
          doc.unset(attr) if doc.attribute(attr)
        end
        if doc.name == "a"
          href = doc.attribute("href").value
          if href =~ %r(^/.+)
            doc.set("href", "https://qiita.com#{href}")
          elsif (href =~ %r(^(http|https)://.+)).nil?
            doc.set("href", "https://qiita.com/#{href}")
          end
        end
      end
      return doc
    end
    # }}}
  # }}}

end

