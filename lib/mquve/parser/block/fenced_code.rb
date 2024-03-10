# frozen_string_literal: true

module Mquve
  class Parser
    class Block
      class FencedCode
        def process(state)
          unless state.in?(Node::CodeBlock)
            return false if state.content.match(/(~{3,}\s~+)/)
            return false if state.content.match(/(`{3,}\s`+)/)

            match = state.content.match(/^ {,3}(?<mark>(`{3,}|~{3,}))[ \t]*(?<info>\S*)[ \t]*(?<after>.*)\n$/)
            return false unless match
            return false if match[:mark].include?('`') && match[:after].match?(/`/)

            state.indent = state.non_space
            state.close! if state.in?(Node::Paragraph)
            code_block = Node::CodeBlock.new(string_content: '', attrs: { info: match[:info].strip, fenced: true, mark: match[:mark] })
            state.open!(code_block)
            return true
          end

          return false unless state.bottom.attrs[:mark]

          match = state.content.match(/^ {,3}#{state.bottom.attrs[:mark][0]}{#{state.bottom.attrs[:mark].length},}\n$/)
          if match
            state.close!
            return true
          end

          false
        end
      end
    end
  end
end
