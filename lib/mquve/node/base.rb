# frozen_string_literal: true

module Mquve
  class Node
    class Base
      attr_accessor :inner, :outer, :children, :attrs, :string_content, :parent

      def initialize(parent: nil, attrs: {}, string_content: '')
        @parent = parent
        @string_content = string_content
        @children = []
        @attrs = attrs
      end

      def inner_html
        children.map(&:outer_html).join
      end

      def inlinize(pending_links)
        Mquve::Parser::Inline.new.process(self, pending_links)
      end

      alias outer_html inner_html
      alias html outer_html
    end
  end
end
