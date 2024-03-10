# frozen_string_literal: true

require_relative 'parser/block'
require_relative 'parser/inline'

module Mquve
  class Parser
    def self.process(doc)
      Block.new.process(doc)
    end
  end
end
