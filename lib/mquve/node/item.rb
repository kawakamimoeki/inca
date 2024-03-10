# frozen_string_literal: true

require 'mquve/node/base'

module Mquve
  class Node
    class Item < Base
      def outer_html
        "<li>#{br? ? "\n" : ''}#{inner_html}</li>\n"
      end

      def br?
        return true unless children.first.instance_of?(Node::Paragraph)
        return false if parent.attrs[:tight]
        return false if children.length == 1

        true
      end
    end
  end
end
