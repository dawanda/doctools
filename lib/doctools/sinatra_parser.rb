module Doctools
  class SinatraParser
    def initialize(text)
      @text = text
    end

    def lines
      @text.split("\n").
        grep(/^\s*(get|post|delete) ['"]/).
        map(&:strip)
    end
  end
end
