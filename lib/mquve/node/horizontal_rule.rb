# frozen_string_literal: true

require 'mquve/node/base'

module Mquve
  class Node
    class HorizontalRule < Base
      def outer_html
        "<hr />\n"
      end

      def inlinize(_)
        self
      end
    end
  end
end
