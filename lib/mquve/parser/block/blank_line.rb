# frozen_string_literal: true

module Mquve
  class Parser
    class Block
      class BlankLine
        def process(state)

          match = state.content.match(/^[ \t]*\n$/)
          return false unless match

          if state.pending_links.last && state.pending_links.last[:in_title]
            dead_link = state.pending_links.pop
            state.store!(Node::Paragraph.new(string_content: dead_link[:text]))
          end

          if state.pending_links.last && state.pending_links.last[:pending] && !state.pending_links.last[:destination]
            dead_link = state.pending_links.pop
            state.store!(Node::Paragraph.new(string_content: dead_link[:text]))
          end

          state.pending_links.last[:pending] = false if state.pending_links.last && state.pending_links.last[:pending] && state.pending_links.last[:destination]

          state.close! until state.bottom.instance_of?(state.line_nodes.last.class) if state.under?(Mquve::Node::BlockQuote) || !state.under?(Node::Item) && !state.in?(Mquve::Node::CodeBlock) && !state.bottom.attrs[:contain]
          state.close! if state.under?(Node::Item)

          state.current_list.attrs[:tight] = false if state.under?(Node::List) && !state.under?(Node::CodeBlock) && !state.under?(Node::BlockQuote)

          state.non_space = 0
          state.content.chars.each do |char|
            if char == "\t"
              state.non_space += 3
            elsif char == ' '
              state.non_space += 1
            else
              break
            end
          end

          if state.in_fence? || (state.in_html? && state.bottom.attrs[:contain])
            state.store!(state.content)
            return true
          end

          state.content = "\n"
          (state.non_space - 4).times { state.content = " #{state.content}" }

          state.store!(state.content) if state.under?(Node::CodeBlock)

          true
        end
      end
    end
  end
end
