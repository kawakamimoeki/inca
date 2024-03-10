# frozen_string_literal: true

require 'mquve/node/base'

module Mquve
  class Node
    class LineBreak < Base
      def inner_html
        '<br />'
      end

      def inlinize(_)
        self
      end

      alias outer_html inner_html
    end
  end
end
