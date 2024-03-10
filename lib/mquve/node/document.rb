# frozen_string_literal: true

module Mquve
  class Node
    class Document < Base
      alias outer_html inner_html
    end
  end
end
