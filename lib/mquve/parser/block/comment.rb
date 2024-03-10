# frozen_string_literal: true

module Mquve
  class Parser
    class Block
      class Comment
        def process(state)
          match = state.content.match(/<!-{2,}.*-{2,}>\n/)
          return false unless match

          state.close! until state.in?(Node::Document)
          comment = Node::HtmlBlock.new(string_content: match[0], parent: state.bottom)
          state.store!(comment)
          true
        end
      end
    end
  end
end
