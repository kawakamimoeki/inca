# frozen_string_literal: true

require 'mquve/node/base'

module Mquve
  class Node
    class Italic < Base
      def outer_html
        "<em>#{inner_html}</em>"
      end
    end
  end
end
