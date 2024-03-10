# frozen_string_literal: true

require 'mquve/node/base'

module Mquve
  class Node
    class Link < Base
      ESCAPE = {
        '\\*' => '*'
      }

      def outer_html
        title = attrs[:title]
        destination = attrs[:destination]
        ESCAPE.each do |k, v|
          title = title&.gsub(k, v)
          destination = destination&.gsub(k, v)
        end
        "<a href=\"#{destination}\"#{title && !title.empty? ? " title=\"#{title}\"" : ''}>#{inner_html}</a>"
      end
    end
  end
end
