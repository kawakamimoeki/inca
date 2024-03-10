# frozen_string_literal: true

require 'mquve/node/base'

module Mquve
  class Node
    class Paragraph < Base
      def outer_html
        h = inner_html
        if parent.instance_of?(Item) && parent.parent.attrs[:tight]
          return "#{h}\n" if parent.children.length > 1

          return h
        end

        "<p>#{inner_html.chomp}</p>\n"
      end
    end
  end
end
