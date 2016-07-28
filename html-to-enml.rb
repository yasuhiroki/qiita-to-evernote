require 'oga'

class QiitaToEvernote

  ENML_PROHIBITED_ATTRIBUTES = [
    "id", "class", "onclick", "ondblclick", "accesskey",
    "data", "dynsrc", "tabindex", "data-lang", "data-conversation",
    "data-partner", "alt"
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

    doc = remove_attr(Oga.parse_html(html))
    doc = replace_pre_to_code(doc)
    body = doc.to_xml.to_s

    content = "#{ENML_HEADER}"
    content << "<en-note>"
    content << doc.to_xml.to_s
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
    filter.words = 'intitle:"' + title + '"'

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

    P_CODE_BLOCK_STYLE = {
      "border-top-right-radius": "3px",
      "border-top-left-radius": "3px",
      "border-bottom-right-radius": "3px",
      "border-bottom-left-radius": "3px",
      "background": "#f7f7f7",
      "margin": "1em 0",
    }

    CODE_BLOCK_STYLE = {
      "border-top-right-radius": "3px",
      "border-top-left-radius": "3px",
      "border-bottom-right-radius": "3px",
      "border-bottom-left-radius": "3px",
      "background": "#f7f7f7",
      "margin": "0 0",
      "padding": ".6em 1.2em",
    }

    def replace_pre_to_code(doc) # {{{
      if doc.respond_to?(:children)
        doc.children.each do |doc_c|
          replace_pre_to_code(doc_c)
        end
      end

      return doc unless doc.respond_to?(:name)

      if doc.name == "pre" && doc.parent.respond_to?("name")
        doc.name = "code"
        doc.set("style", CODE_BLOCK_STYLE.map{|k,v| "#{k}: #{v}"}.join(";"))
        doc.parent.set("style", P_CODE_BLOCK_STYLE.map{|k,v| "#{k}: #{v}"}.join(";"))
      end
      return doc
    end
    # }}}
  # }}}

end

