# frozen_string_literal: true

module Mquve
  class Parser
    class Block
      class LinkReferenceDefinition
        def process(state)
          return false if state.in?(Node::Paragraph)

          if match = state.content.match(/^[ \t]*\[(?<content>.+)\]:[ \t]*(?<destination>.+)[ \t]+(&quot;|')(?<title>(\w|\s|\)|\(|\\&quot;|\\|\*)*\n?)(?<closing>(&quot;|')?)\n?$/)
            destination = match[:destination]
            destination = destination.gsub(/(^<|>$)/, '')
            state.pending_links << { text: match[0], string_content: match[:content], destination: destination.strip, title: match[:title], in_title: match[:closing].empty? }
            return true
          end

          if match = state.content.match(/^[ \t]*\[(?<content>.+)\]:[ \t]*<(?<destination>\S*)>\n/)
            destination = match[:destination]
            destination = destination.gsub(/(^<|>$)/, '')
            state.pending_links << { text: match[0], string_content: match[:content], destination: destination.strip }
            return true
          end

          if match = state.content.match(/^[ \t]*\[(?<content>.+)\]:[ \t]*(?<destination>(\/|\w|-|_)+)\n/)
            destination = match[:destination]
            destination = destination.gsub(/(^<|>$)/, '')
            state.pending_links << { text: match[0], string_content: match[:content], destination: destination.strip, pending: true, title: '' }
            return true
          end

          if match = state.content.match(/^[ \t]*\[(?<content>.+)\]:[ \t]*\n/)
            state.pending_links << { text: match[0], string_content: match[:content], pending: true, title: '' }
            return true
          end

          if match = state.content.match(/^[ \t]*\[[ \t]*\n/)
            state.pending_links << { text: match[0], string_content: '', in_content: true }
            return true
          end

          return false unless state.pending_links.last

          if !state.pending_links.last[:destination] && match = state.content.match(/^[ \t]*<(?<destination>.+)>/)
            state.pending_links.last[:destination] = match[:destination]
            return true
          end

          if state.pending_links.last[:pending] && match = state.content.match(/^[ \t]*(&quot;|')(?<title>.+)(&quot;|')[ \t]*\n/)
            state.pending_links.last[:title] += match[:title]
            return true
          end

          if state.pending_links.last[:in_title] && state.content.match(/[ \t]*(&quot;|')\n/)
            state.pending_links.last[:in_title] = false
            return true
          end

          if state.pending_links.last[:in_content] && match = state.content.match(/^[ \t]*(?<content>.*)\]:[ \t]*(?<destination>.*)[ \t]*\n/)
            state.pending_links.last[:text] += match[0]
            state.pending_links.last[:in_content] = false
            state.pending_links.last[:string_content] += match[:content]
            state.pending_links.last[:destination] = match[:destination]
            return true
          end

          if state.pending_links.last[:in_title]
            state.pending_links.last[:title] += state.content
            return true
          end

          if state.pending_links.last[:in_content]
            state.pending_links.last[:text] += state.content
            state.pending_links.last[:string_content] += state.content
            return true
          end

          unless state.pending_links.last[:destination]
            state.pending_links.last[:destination] = state.content.strip
            return true
          end

          false
        end
      end
    end
  end
end
