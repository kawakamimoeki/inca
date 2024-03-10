# frozen_string_literal: true

module Mquve
  class Parser
    class Inline
      class State
        attr_accessor :nodes, :escaped, :pending_link

        def initialize
          @nodes = []
          @escaped = false
          @pending_link = nil
        end

        def escaped?
          escaped
        end

        def has?(text)
          nodes.find { _1.string_content == text }
        end

        def current_link
          nodes.find { _1.instance_of?(Node::Image) || _1.instance_of?(Node::Link) }
        end

        def store!(char)
          if !nodes.last || nodes.last.attrs[:delimiter] || !nodes.last.instance_of?(Node::Text)
            nodes << Node::Text.new(string_content: char)
            return
          end

          nodes.last.string_content += char
        end
      end

      def process(parent, pending_links)
        link_definitionas = pending_links
        content = parent.string_content
        content = content.chomp unless parent.instance_of?(Node::CodeBlock)
        scanner = StringScanner.new(content)
        state = State.new
        until scanner.eos?
          if (scan = scanner.scan(/<\/?[\w\d-]+( |\t|\w|\d|&quot;|=)*>/))
            state.nodes << Node::HtmlInline.new(string_content: scan)
            next
          end

          if state.nodes.find { _1.attrs[:delimiter] && _1.string_content == '&quot;' } && scanner.scan(/&quot;/)
            state.nodes << Node::Text.new(string_content: '&quot;', attrs: { delimiter: true })
            next
          end

          if state.nodes.find { _1.attrs[:delimiter] && _1.string_content == '(' } && scanner.scan(/ &quot;/)
            state.nodes << Node::Text.new(string_content: ' ', attrs: { delimiter: true })
            state.nodes << Node::Text.new(string_content: '&quot;', attrs: { delimiter: true })
            next
          end

          if state.nodes.find { _1.string_content == '(' && _1.attrs[:delimiter] } && scanner.scan(/\)/)
            link = Node::Link.new(attrs: { title: '' })
            loop do
              text = "#{state.nodes.pop.string_content}#{text}"
              break if text == '&quot;'
            end
            if state.nodes.find { _1.attrs[:delimiter] && _1.string_content == '&quot;' }
              until state.nodes.last.string_content == '&quot;'
                string = state.nodes.pop.string_content
                link.attrs[:title] = "#{string}#{link.attrs[:title]}"
              end
            end
            state.nodes.pop # &quot;
            state.nodes.pop
            href = ''
            href = "#{state.nodes.pop.string_content}#{href}" until state.nodes.last.string_content == '('
            { '\\' => '' }.each do |k, v|
              href = href.gsub(k, v)
            end
            link.attrs[:destination] = href
            state.nodes.pop until state.nodes.last.string_content == ']'
            state.nodes.pop # ]
            text = Node::Text.new(string_content: state.nodes.pop.string_content, parent: link)
            link.children << text
            state.nodes.pop # [
            parent.children << link
            state.escaped = false
            next
          end

          if state.nodes.find { _1.string_content == '<' && _1.attrs[:delimiter] } && scanner.scan(/>/)
            text = ''
            text = "#{state.nodes.pop.string_content}#{text}" until state.nodes.last.string_content == '<'
            text = Node::Text.new(string_content: text)
            state.nodes.pop # <
            href = text.string_content
            { '\\' => '%5C' }.each do |k, v|
              href = href.gsub(k, v)
            end
            link = Node::Link.new(attrs: { destination: href })
            link.children << text
            text.parent = link
            parent.children << link
            next
          end

          if state.nodes.last && state.nodes.last.attrs[:delimiter] && state.nodes.last.string_content == ']' && scanner.scan(/\(/)
            state.nodes << Node::Text.new(string_content: '(', attrs: { delimiter: true })
            next
          end

          if state.nodes.find { _1.string_content == '![' } && scanner.scan(/]/)
            image = Node::Image.new
            image.children << state.nodes.pop until state.nodes.last.string_content == '!['
            state.nodes.pop
            state.nodes << image
            next
          end

          if state.nodes.find { _1.string_content == '[' && _1.attrs[:delimiter] } && scan = scanner.scan(/]/)
            # link = Node::Link.new
            # link.children << state.nodes.pop until state.nodes.last.string_content == '['
            # state.nodes.pop
            # state.nodes << link
            if state.pending_link
              text = ''
              text = "#{state.nodes.pop.string_content}#{text}" until state.nodes.last.string_content == '['
              state.nodes.pop
              link = Node::Link.new(attrs: { destination: state.pending_link[:destination].gsub('\\*', '*').gsub(' ', '%20').gsub('\\', '%5C'), title: state.pending_link[:title]&.gsub('\\&quot;', '&quot;') })
              link.children << Node::Text.new(string_content: text)
              parent.children << link
              link_definitionas = link_definitionas.reject { _1 == state.pending_link }
              next
            end
            state.nodes << Node::Text.new(string_content: scan, attrs: { delimiter: true })
            next
          end

          node = state.nodes.find { _1.attrs[:delimiter] && _1.string_content.match(/^`{1,}$/) }
          if node && scanner.scan(/`{#{node.string_content.length}}/)
            text = ''
            loop do
              n = state.nodes.pop
              break if n.string_content == node.string_content

              text = "#{n.string_content}#{text}"
            end
            text = text.strip unless text == ' '
            parent.children << Node::CodeSpan.new(string_content: text)
            state.nodes.pop
            next
          end

          if (node = state.nodes.find { _1.string_content == '*' && _1.attrs[:delimiter] }) && scanner.scan(/\*/) || ((node = state.nodes.find { _1.string_content == '_' && _1.attrs[:delimiter] }) && scanner.scan(/_/))
            text = ''
            text = "#{state.nodes.pop.string_content}#{text}" until state.nodes.last == node
            text = Node::Text.new(string_content: text)
            emph = Node::Emph.new
            emph.children << text
            parent.children << emph
            state.nodes.pop # "*"
            next
          end

          scan = scanner.scan(/`{1,}/)
          if scan
            if !state.escaped? && !state.nodes.find { _1.string_content.match(/^`{1,}$/) && _1.attrs[:delimiter] }
              state.nodes << Node::Text.new(string_content: scan, attrs: { delimiter: true })
              state.escaped = false
              next
            end

            state.store!(scan)
            next
          end

          scan = scanner.scan(/[*_]\S/)
          if scan
            scanner.pos -= 1
            if state.escaped? || scan[1] == '*' || scan[1] == '_'
              state.store!(scan[0])
              next
            end
            parent.children << state.nodes.pop if state.nodes.length.positive? && state.nodes.none? { _1.attrs[:delimiter] }
            state.nodes << Node::Text.new(string_content: scan[0], attrs: { delimiter: true })
            next
          end

          scan = scanner.scan(/!\[/)
          if scan
            state.nodes << Node::Text.new(string_content: scan, attrs: { delimiter: true })
            next
          end

          if state.nodes.last && state.nodes.last.string_content == '[' && state.nodes.last.attrs[:delimiter]
            link_definitionas.reverse.each do |definition|
              scan = scanner.check(/^#{Regexp.escape(definition[:string_content])}/i)
              state.pending_link = definition if scan
            end
          end

          scan = scanner.scan(/\[/)
          if scan
            parent.children << Node::Text.new(string_content: state.nodes.slice!(0).string_content) until state.nodes.empty?
            unless state.escaped?
              state.nodes << Node::Text.new(string_content: scan, attrs: { delimiter: true })
              next
            end
            state.nodes << Node::Text.new(string_content: scan)
            next
          end

          scan = scanner.scan(/</)
          if scan
            if scanner.check(/https?:\/\//)
              state.nodes << Node::Text.new(string_content: scan, attrs: { delimiter: true })
              next
            end

            state.store!(scan)
            next
          end

          scan = scanner.scan(/(\\| {2,})$/) unless parent.instance_of?(Node::Heading)
          if scan
            parent.children << state.nodes.pop
            parent.children << Node::LineBreak.new
            next
          end

          if !state.escaped? && (scan = scanner.scan(/\\(!|"|#|\$|%|&|'\(|\)|\*|\+|,|-|\.|\/|:|;|<|=|>|\?|@|\[|\\|\]|\^|_|`|\{|\||\}|~)/))
            state.nodes << Node::Text.new(string_content: scan)
            next
          end

          scan = scanner.scan(/\\/)
          if scan
            state.store!(scan)
            state.escaped = !state.escaped? unless parent.instance_of?(Node::CodeBlock)
            next
          end

          scan = scanner.scan(/\n/)
          if scan
            state.nodes << Mquve::Node::SoftBreak.new(string_content: scan)
            next
          end

          char = scanner.string[scanner.charpos]
          state.store!(char)
          state.escaped = false

          scanner.scan(/./)
        end

        if parent.instance_of?(Node::CodeBlock)
          parent.string_content = state.nodes.map(&:string_content).join
          return parent
        end

        state.nodes.map do |node|
          return node if node.instance_of?(Mquve::Node::CodeSpan)

          if match = node.string_content.match(/\\(!|"|#|\$|%|&|'\(|\)|\*|\+|,|-|\.|\/|:|;|<|=|>|\?|@|\[|\\|\]|\^|_|`|\{|\||\}|~)/)
            node.string_content = node.string_content.gsub(match[0], match[1])
          end

          node
        end

        parent.children += state.nodes

        parent
      end
    end
  end
end
