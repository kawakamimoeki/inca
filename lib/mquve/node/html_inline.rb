# frozen_string_literal: true

require 'mquve/node/base'

module Mquve
  class Node
    class HtmlInline < Base
      ESCAPE = {
        '&quot;' => '"',
        '&lt;' => '<',
        '&gt;' => '>'
      }.freeze

      def outer_html
        content = string_content
        ESCAPE.each do |k, v|
          content = content.gsub(k, v)
        end
        content
      end
    end
  end
end
