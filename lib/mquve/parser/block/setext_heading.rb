# frozen_string_literal: true

module Mquve
  class Parser
    class Block
      class SetextHeading
        def process(state)
          return false unless state.in?(Node::Paragraph)
          return false if state.under?(Node::BlockQuote)
          return false if state.under?(Node::List)

          match = state.content.match(/^[ \t]{,3}(=+|-+)\s*$/)
          return false unless match

          paragraph = state.nodes.pop
          heading = Mquve::Node::Heading.new(string_content: paragraph.string_content, attrs: { level: match[0].include?('=') ? 1 : 2 })
          state.store!(heading)
          true
        end
      end
    end
  end
end
