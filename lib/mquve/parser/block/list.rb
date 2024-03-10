# frozen_string_literal: true

module Mquve
  class Parser
    class Block
      class List
        def process(state)
          match = state.content.match(/^(?<init_space>[ \t]*)((?<mark>(?<bullet>[-*+]))|(?<mark>(?<num>[0-9]{,9})(?<delimiter>(\.|\)))))[ \t]/)

          return state unless match

          non_space = 0
          match[:init_space]&.chars&.each do |char|
            if char == "\t"
              non_space += 4
            elsif char == ' '
              non_space += 1
            else
              break
            end
          end

          offset = 0
          match[0].chars.each do |char|
            if char == "\t"
              offset += 4
              next
            else
              offset += 1
            end
          end

          return state if non_space >= state.current_list.attrs[:offset] + 4

          state.close! if state.in?(Node::Paragraph)
          state.close! if state.in?(Node::HtmlBlock)
          delimiter = nil unless match[:delimiter]
          delimiter = :period if match[:delimiter] == '.'
          delimiter = :paren if match[:delimiter] == ')'
          list = Node::List.new(attrs: { tight: true, type: match[:bullet] ? :bullet : :ordered, bullet: match[:bullet], delimiter: delimiter, offset: offset, non_space: non_space })
          state.line_nodes << list
          state.line_nodes << Node::Item.new(parent: list)
          state.content = state.content.match(/#{Regexp.escape(match[:mark])}(?<content>.*\n)/)[:content]

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

          state.content = state.content.match(/( |\t)*(?<content>.*\n)/)[:content]
          non_space.times { state.content = " #{state.content}" }

          state
        end
      end
    end
  end
end
