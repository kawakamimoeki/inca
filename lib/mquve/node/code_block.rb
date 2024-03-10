# frozen_string_literal: true

require 'mquve/node/text'
require 'mquve/node/base'

module Mquve
  class Node
    class CodeBlock < Base
      ESCAPE = {
        '\+' => '+',
        '>' => '&gt;',
        '<' => '&lt;',
        /\A\n*(.*\n)\n\n\Z/ => '\1'
      }.freeze

      def outer_html
        info = attrs[:info]
        content = string_content
        ESCAPE.each do |k, v|
          info = info&.gsub(k, v)
          content = content&.gsub(k, v)
        end
        "<pre><code#{info && !info.empty? ? " class=\"language-#{info}\"" : ''}>#{content}</code></pre>\n"
      end

      def inlinize(_)
        self
      end
    end
  end
end
