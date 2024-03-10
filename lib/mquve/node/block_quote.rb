# frozen_string_literal: true

require 'mquve/node/base'

module Mquve
  class Node
    class BlockQuote < Base
      def outer_html
        "<blockquote>\n#{inner_html}</blockquote>\n"
      end

      alias html outer_html
    end
  end
end
