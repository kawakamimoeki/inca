# frozen_string_literal: true

require 'mquve/node/base'

module Mquve
  class Node
    class Image < Base
      def outer_html
        "<img src=\"#{attrs[:destination]}\" alt=\"#{children.map(&:string_content).join}\" #{attrs[:title] ? "title=\"#{attrs[:title]}\" " : ''}/>"
      end
    end
  end
end
