# frozen_string_literal: true

module Mquve
  class Converter
    def self.process(text)
      doc = Mquve::Node::Document.new(string_content: text, attrs: { offset: 0, non_space: 0 })
      doc = Mquve::Parser.process(doc)
      doc.outer_html
    end
  end
end
