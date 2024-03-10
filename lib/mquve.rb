# frozen_string_literal: true

require 'cgi'
require 'strscan'
require 'mquve/node/base'
require 'mquve/node/document'
require 'mquve/node/heading'
require 'mquve/node/paragraph'
require 'mquve/node/code_block'
require 'mquve/node/horizontal_rule'
require 'mquve/node/block_quote'
require 'mquve/node/emph'
require 'mquve/node/italic'
require 'mquve/node/strikethrough'
require 'mquve/node/line_break'
require 'mquve/node/link'
require 'mquve/node/image'
require 'mquve/node/code_span'
require 'mquve/node/text'
require 'mquve/node/list'
require 'mquve/node/item'
require 'mquve/node/soft_break'
require 'mquve/node/html_block'
require 'mquve/node/html_inline'
require 'mquve/version'
require 'mquve/converter'
require 'mquve/parser'
require 'mquve/parser/block/blank_line'
require 'mquve/parser/block/list'
require 'mquve/parser/block/fenced_code'
require 'mquve/parser/block/html_block'
require 'mquve/parser/block/block_quote'
require 'mquve/parser/block/indented_code'
require 'mquve/parser/block/setext_heading'
require 'mquve/parser/block/horizontal_rule'
require 'mquve/parser/block/atx_heading'
require 'mquve/parser/block/string'
require 'mquve/parser/block/comment'
require 'mquve/parser/block/link_reference_definition'

module Mquve
  class Error < StandardError; end

  def self.to_html(text)
    raise TypeError, "Text must be a String; got a #{text.class}." unless text.is_a?(String)
    raise TypeError, "Text must be UTF-8 encoded; got #{text.encoding}." unless text.encoding.name == 'UTF-8'

    Converter.process(text)
  end

  def self.parse(text, &block)
    doc = Node.new(type: :document, source: { content: text, begin: 0, end: text.length - 1 })
    doc = Parser.process(doc)
    call_children(doc, block)
  end

  def self.call_children(parent, block)
    parent.children.each do |child|
      block.call(child)
      call_children(child, block)
    end
  end

  def self.to_document(text)
    doc = Node::Document.new(text)
    Parser.process(doc)
  end
end
