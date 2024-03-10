# frozen_string_literal: true

module Mquve
  class Parser
    class Block
      class String
        def process(state)
          if state.in_fence?
            state.content.chars.each do |char|
              if char == "\t"
                state.non_space += 4
              elsif char == ' '
                state.non_space += 1
              else
                break
              end
            end

            state.content = state.content.match(/[ \t]*(?<content>.*\n)/)[:content]
            (state.non_space - state.indent).times { state.content = " #{state.content}" }
            state.store!(state.content)
            return state
          end

          state.current_list.attrs[:tight] = false if state.current_list && state.current_list.attrs[:widable]

          content = state.content
          content = content.gsub(/^[ \t]*/, '') if state.in?(Node::Paragraph)

          if state.in?(Node::CodeBlock)
            state.close!
            state.open!(Node::Paragraph.new)
          end

          state.bottom.string_content += content

          state
        end
      end
    end
  end
end
