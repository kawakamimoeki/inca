# frozen_string_literal: true

module Mquve
  class Parser
    class Block
      class IndentedCode
        def process(state)
          return false if state.in?(Node::Paragraph)

          match = state.content.match(/^(?<space> {4})(?<content>.*\n)/)

          return false unless match

          state.content = match[:content]
          state.close! until state.line_nodes.last.instance_of?(state.nodes.last.class) if state.under?(Node::BlockQuote)

          if state.in?(Node::CodeBlock)
            state.store!(state.content)
            return state
          end
          code_block = Node::CodeBlock.new(string_content: state.content)
          state.open!(code_block)
          true
        end
      end
    end
  end
end
