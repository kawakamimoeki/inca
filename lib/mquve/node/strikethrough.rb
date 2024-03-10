# frozen_string_literal: true

require 'mquve/node/base'

module Mquve
  class Node
    class Strikethrough < Base
      def outer_html
        "<del>#{inner_html}</del>"
      end
    end
  end
end
