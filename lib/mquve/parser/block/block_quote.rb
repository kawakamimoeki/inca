# frozen_string_literal: true

module Mquve
  class Parser
    class Block
      class BlockQuote
        def process(state)
          match = state.content.match(/^(?<mark>(\s{,3}>))(?<content>.*\n)$/)
          return state unless match

          state.line_nodes << Node::BlockQuote.new
          state.content = match[:content]
          non_space = 0

          state.content.chars.each do |char|
            if char == "\t"
              non_space += 3
            elsif char == ' '
              non_space += 1
            else
              break
            end
          end

          state.content = state.content.match(/[ \t]*(?<content>.*\n)/)[:content]
          non_space.times { state.content = " #{state.content}" }

          state
        end
      end
    end
  end
end
