# frozen_string_literal: true

require 'mquve/node/base'

module Mquve
  class Node
    class Text < Base
      def inlinize(_)
        self
      end

      ESCAPE = {
        '\+' => '+',
        '>' => '&gt;',
        '<' => '&lt;',
        / +\n/ => "\n"
      }.freeze

      def outer_html
        content = string_content
        ESCAPE.each do |k, v|
          content = content.gsub(k, v)
        end
        content = content.gsub(/\\([&<>"!#$%'()*+-.\/:;=?@\[\\\]^_`{|}~])/, '\1') if !parent.instance_of?(Node::CodeBlock) && !parent.instance_of?(Node::Link)
        content
      end
    end
  end
end
