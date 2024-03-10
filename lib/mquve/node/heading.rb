# frozen_string_literal: true

require 'mquve/node/base'

module Mquve
  class Node
    class Heading < Base
      def outer_html
        "<h#{attrs[:level]}>#{inner_html.strip}</h#{attrs[:level]}>\n"
      end
    end
  end
end
