# frozen_string_literal: true

module Mquve
  class Parser
    class Block
      class HorizontalRule
        def process(state)
          return false unless state.non_space < 4

          match = state.content.match(/^[ \t]{,3}((\*\s*\t*){3,}|(-\s*\t*){3,}|(_\s*\t*){3,})$/)

          return false unless match

          return false if state.in?(Node::Paragraph) && match[0].match(/-+/) && !match[0].match(/-\s-/) && !state.under?(Node::BlockQuote) && !state.under?(Node::List)

          state.close! until state.in?(Node::Document) if state.non_space.zero?

          horizontal_rule = Node::HorizontalRule.new
          state.line_nodes << horizontal_rule
          true
        end
      end
    end
  end
end
