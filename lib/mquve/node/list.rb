# frozen_string_literal: true

require 'mquve/node/base'

module Mquve
  class Node
    class List < Base
      def tag
        attrs[:type] == :ordered ? 'ol' : 'ul'
      end

      def outer_html
        "#{parent.instance_of?(Node::Item) && parent.parent.attrs[:tight] ? "\n" : ''}<#{tag}#{attrs[:start] && attrs[:start] > 1 ? " start=\"#{attrs[:start]}\"" : ''}>\n#{inner_html}</#{tag}>\n"
      end
    end
  end
end
