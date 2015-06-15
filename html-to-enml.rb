require 'oga'

class QiitaToEvernote

  ENML_PROHIBITED_ATTRIBUTES = [
    "id", "class", "onclick", "ondblclick", "accesskey",
    "data", "dynsrc", "tabindex", "data-lang"
  ]

  def to_enml_from(html) # {{{
    return remove_attr(Oga.parse_html(html)).to_xml
  end
  # }}}

  private
    def remove_attr(doc)
      if doc.respond_to?(:children)
        doc.children.each do |doc_c|
          remove_attr(doc_c)
        end
      end
      ENML_PROHIBITED_ATTRIBUTES.each do |attr|
        next unless doc.respond_to?(:attribute)
        doc.unset(attr) if doc.attribute(attr)
      end
      return doc
    end

end

