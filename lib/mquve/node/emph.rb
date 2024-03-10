# frozen_string_literal: true

module Mquve
  class Node
    class Emph < Base
      def outer_html
        "<em>#{inner_html}</em>"
      end
    end
  end
end
