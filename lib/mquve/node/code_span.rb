# frozen_string_literal: true

module Mquve
  class Node
    class CodeSpan < Base
      def outer_html
        "<code>#{string_content}</code>"
      end
    end
  end
end
