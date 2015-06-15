require 'oga'

class QiitaToEvernote

  ENML_PROHIBITED_ATTRIBUTES = [
    "id", "class", "onclick", "ondblclick", "accesskey",
    "data", "dynsrc", "tabindex", "data-lang", "data-conversation"
  ]

  def to_enml_from(html) # {{{
    return remove_attr(Oga.parse_html(html)).to_xml
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
  # }}}

end

