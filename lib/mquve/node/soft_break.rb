# frozen_string_literal: true

require 'mquve/node/base'

module Mquve
  class Node
    class SoftBreak < Base
      def inlinize(_)
        self
      end

      def outer_html
        "\n"
      end
    end
  end
end
