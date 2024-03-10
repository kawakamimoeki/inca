# frozen_string_literal: true

module Mquve
  class Parser
    class Block
      class AtxHeading
        def process(state)
          match = state.content.match(/^ {,3}(?<level>\#+)($|(?<content>\s\#+)|\s+(?<content>.*)(\s+\#+)*)\n$/)
          return false unless match && match[:level].length < 7 && !state.in?(Node::CodeBlock)

          state.close! if state.in?(Node::Paragraph)
          content = match[:content]
          content = content.gsub(/\s+\#+\s*$/, '') if content
          content = content.gsub(/\s*$/, '') if content
          content = content.gsub(/^\s*/, '') if content
          content ||= ''
          heading = Node::Heading.new(
            string_content: content,
            parent: state.bottom,
            attrs: { level: match[:level].length }
          )
          state.store!(heading)
          true
        end
      end
    end
  end
end
