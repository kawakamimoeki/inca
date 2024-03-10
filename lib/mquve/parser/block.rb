# frozen_string_literal: true

module Mquve
  class Parser
    class Block
      class State
        attr_accessor :nodes, :content, :list_widable, :indent, :offset, :non_space, :pending_links, :line_nodes

        def initialize(nodes:)
          @nodes = nodes
          @content = ''
          @list_widable = false
          @indent = 0
          @offset = 0
          @non_space = 0
          @pending_links = []
          @line_nodes = []
        end

        def delete!
          nodes.pop
        end

        def close!
          return if nodes.length < 2

          node = delete!
          store!(node)
          node
        end

        def has_block?
          nodes.length > 1 && !has_text?
        end

        def current_list
          nodes.reverse.find { _1.instance_of?(Node::List) } || nodes[0]
        end

        def current_item
          nodes.reverse.find { _1.instance_of?(Node::Item) } || nodes[0]
        end

        def current_quote
          nodes.reverse.find { _1.instance_of?(Node::BlockQuote) } || nodes[0]
        end

        def depth
          current_quote.attrs[:depth]
        end

        def has_text?
          bottom.instance_of?(::String)
        end

        def has_pending_link?
          pending_links.last && pending_links.last[:pending]
        end

        def in?(type)
          bottom.instance_of?(type)
        end

        def in_fence?
          bottom.instance_of?(Mquve::Node::CodeBlock) && bottom.attrs[:fenced]
        end

        def in_html?
          bottom.instance_of?(Mquve::Node::HtmlBlock)
        end

        def should_parse?
          !in_fence? && !in_html?
        end

        def under?(type)
          classes.reverse.find { _1 == type }
        end

        def bottom
          nodes[-1]
        end

        def open!(target)
          nodes << target
        end

        def store!(target)
          if target.instance_of?(::String)
            bottom.string_content += target
            return
          end

          target.string_content = target.string_content.gsub(/ +\n$/, '') if target.instance_of?(Node::Paragraph)
          target.string_content = target.string_content.gsub(/\n\n\n?\Z/, "\n") if target.instance_of?(Node::CodeBlock)

          nodes[-1].children << target
        end

        def store_or_open!(target)
          has_text? ? store!(target) : open!(target)
        end

        def classes
          nodes.map(&:class)
        end
      end

      ESCAPE = {
        '\\&' => '&amp;',
        '\\<' => '&lt;',
        '\\>' => '&gt;',
        '"' => '&quot;'
      }.freeze

      def process(parent)
        ESCAPE.each do |k, v|
          parent.string_content.gsub!(k, v)
        end
        state = State.new(nodes: [parent])

        parent.string_content.lines.each_with_index do |line, i|
          state.content = line
          state.non_space = 0
          state.line_nodes = [Node::Document.new]

          unless state.in_fence?
            state.content.chars.each do |char|
              if char == "\t"
                state.non_space += 4
              elsif char == ' '
                state.non_space += 1
              else
                break
              end
            end
          end


          if !state.in_fence? || state.under?(Node::BlockQuote)
            loop do
              content = state.content
              state = Block::BlockQuote.new.process(state)
              break if HorizontalRule.new.process(state) && state.should_parse?

              state = Block::List.new.process(state)
              break if state.content == content
            end
          end

          state.line_nodes.each_with_index do |node, i|
            unless state.nodes[i]
              if node.instance_of?(Mquve::Node::HorizontalRule)
                state.store!(node)
                break
              end
              state.open!(node)
              next
            end

            if node.instance_of?(state.nodes[i].class)
              if node.instance_of?(Mquve::Node::HorizontalRule)
                state.close!
                state.store!(node)
                break
              end
              if node.instance_of?(Node::Item) && node.parent.attrs[:non_space] < state.nodes[i].parent.attrs[:offset]
                state.close!
                state.open!(node)
                next
              end
              next unless node.instance_of?(Node::Item) && node.parent.attrs[:non_space] >= state.nodes[i].parent.attrs[:offset]

              state.open!(node.parent)
            else
              state.nodes[..i].each { state.close! }
            end
            state.open!(node)
          end

          next if state.line_nodes.last.instance_of?(Mquve::Node::HorizontalRule)

          if state.line_nodes.length == 1
            non_space = 0
            state.content.chars.each do |char|
              if char == "\t"
                non_space += state.line_nodes.length > 1 ? 3 : 4
              elsif char == ' '
                non_space += 1
              else
                break
              end
            end
            state.content = state.content.match(/( |\t)*(?<content>.*\n)/)[:content]
            (non_space - state.current_list.attrs[:offset]).times { state.content = " #{state.content}" }
          end

          next if BlankLine.new.process(state)
          next if SetextHeading.new.process(state) && state.should_parse?
          next if state.in?(Node::Item) && state.bottom.children.empty? && HorizontalRule.new.process(state)
          next if !state.in?(Mquve::Node::HtmlBlock) && FencedCode.new.process(state)
          next if !state.in?(Mquve::Node::HtmlBlock) && !state.has_pending_link? && !state.bottom.attrs[:contain] && IndentedCode.new.process(state)
          next if !state.has_pending_link? && HtmlBlock.new.process(state)
          next if SetextHeading.new.process(state)
          next if !state.in_fence? && LinkReferenceDefinition.new.process(state)
          next if AtxHeading.new.process(state)

          state.open!(Node::Paragraph.new(parent: state.bottom)) if !state.in?(Node::Paragraph) && !state.in?(Mquve::Node::CodeBlock) && !state.in?(Mquve::Node::HtmlBlock) && !state.bottom.attrs[:contain] && !state.content.empty?

          state = String.new.process(state)
        end

        state.close! until state.in?(Node::Document)

        inlinize(parent, state.pending_links)
      end

      def inlinize(parent, pending_links)
        return parent if parent.children.empty? && parent.instance_of?(Node::Document)
        return parent.inlinize(pending_links) if parent.children.empty?

        parent.children.each_with_index do |child, i|
          parent.children[i] = inlinize(child, pending_links)
        end
        parent
      end
    end
  end
end
