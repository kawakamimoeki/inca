# frozen_string_literal: true

module Mquve
  class Parser
    class Block
      class HtmlBlock
        PRIORITY = %w[pre script style textarea].freeze
        NONPRIORITY = %w[address article aside base basefont blockquote body caption center col colgroup dd details dialog dir div dl dt fieldset figcaption figure footer form frame frameset h1 h2 h3 h4 h5 h6 head header hr html iframe legend li link main menu menuitem nav noframes ol optgroup option p param search section summary table tbody td tfoot th thead title tr track ul].freeze
        TAGS = PRIORITY + NONPRIORITY

        def process(state)
          if state.in?(Mquve::Node::HtmlBlock) && state.bottom.attrs[:comment] && state.content.match(/-{2,}>/)
            state.store!(state.content)
            state.close!
            return true
          end

          if state.in?(Mquve::Node::HtmlBlock) && state.bottom.attrs[:processing] && state.content.match(/\?>/)
            state.store!(state.content)
            state.close!
            return true
          end

          if state.in?(Mquve::Node::HtmlBlock) && state.bottom.attrs[:cdata] && state.content.match(/\]\]>/)
            state.store!(state.content)
            state.close!
            return true
          end

          if state.in?(Mquve::Node::HtmlBlock) && !state.bottom.attrs[:cdata] && !state.bottom.attrs[:processing] && !state.bottom.attrs[:comment] && state.bottom.attrs[:contain] && state.content.match(/#{state.bottom.attrs[:tags].reverse.map { ".*<\/#{_1}>" }.join}/)
            state.store!(state.content)
            state.close!
            return true
          end

          if (state.in?(Mquve::Node::Paragraph) || state.in?(Mquve::Node::HtmlBlock)) && match = state.content.match(/^[ \t]*<\/?((?<tag>#{self.class::PRIORITY.join('|')}))[ \t]*.*[>\n]/i)
            state.store!(match[0])
            return true
          end

          if state.in?(Mquve::Node::HtmlBlock) && match = state.content.match(/^[ \t]*<\/?((?<tag>#{self.class::NONPRIORITY.join('|')}))[ \t]*.*[>\n]/i)
            state.store!(match[0])
            return true
          end

          match ||= state.content.match(/^[ \t]*<((?<tag>(#{self.class::PRIORITY.join('|')})).*)+(?<after>)\n/i)
          contain = true if match
          match ||= state.content.match(/^[ \t]*<\/?(?<tag>(#{self.class::NONPRIORITY.join('|')}))(?<after>.*)\n/i)
          match7 = state.content.match(/^[ \t]*<(?<tag>[\w\d-]+)(\s|\t|\w|\d|-|&quot;|=|\)|\(|\/|\\)*>\n/i)
          match7 ||= state.content.match(/^[ \t]*<\/(?<tag>[\w\d-]+)>\n/i)
          match ||= match7 if match7 && !state.in?(Node::Paragraph)
          if comment_match = state.content.match(/^[ \t]*<!-{2,}(?<tag>).*\n/i)
            match ||= comment_match
            if match[0].match(/-{2,}>/)
              html_block = Node::HtmlBlock.new(string_content: match[0], attrs: { contain: true, comment: true })
              state.store!(html_block)
              return true
            end

            comment = true
            contain = true
          end
          if processing_match = state.content.match(/^[ \t]*<\?[\w\d-].*\n/)
            match ||= processing_match
            if match[0].match(/\?>/)
              html_block = Node::HtmlBlock.new(string_content: match[0], attrs: { contain: true, processing: true })
              state.store!(html_block)
              return true
            end

            processing = true
            contain = true
          end

          if doctype_match = state.content.match(/<!DOCTYPE html>\n/)
            match ||= doctype_match
            html_block = Node::HtmlBlock.new(string_content: match[0], attrs: { contain: true })
            state.store!(html_block)
            return true
          end

          if cdata_match = state.content.match(/<!\[CDATA\[\n/)
            match ||= cdata_match
            contain = true
            cdata = true
          end
          return false unless match
          return false if match[1]&.match?(/https?:\/\//i)

          tags = match[0].split(/(<[\w\d-]+)[ \t]*/).each_slice(2).map(&:last)[..-2].map { _1[1..] }

          if contain && match[0].match(/<\/#{tags[-1]}>/)
            html_block = Node::HtmlBlock.new(string_content: match[0], attrs: { tags: tags, contain: contain })
            state.store!(html_block)
            return true
          end

          state.close! until state.in?(Mquve::Node::BlockQuote) || state.in?(Mquve::Node::Paragraph) || state.in?(Mquve::Node::Document) || state.in?(Node::Item)
          state.close! if state.in?(Mquve::Node::Paragraph)

          if state.in?(Node::HtmlBlock)
            state.store!(match[0])
            return true
          end

          html_block = Node::HtmlBlock.new(string_content: match[0], attrs: { comment: comment, tags: tags, contain: contain, processing: processing, cdata: cdata })
          state.open!(html_block)
          true
        end
      end
    end
  end
end
