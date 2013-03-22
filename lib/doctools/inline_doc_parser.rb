require 'ripper'
require 'doctools/inline_doc'

module Doctools
  # This class attempts to parse the given text as ruby code and collect
  # documented classes and functions.
  #
  class InlineDocParser
    def initialize(text)
      @text = text
    end

    def parse
      docs                 = []
      current_comments     = []
      symbol_type          = nil
      symbol_name          = nil
      symbol_documentation = nil

      Ripper.lex(@text).each do |node|
        _, name, body = node

        if name == :on_comment
          # store the comment for later
          current_comments << body
        elsif name == :on_kw and (body == 'class' or body == 'def')
          # found a symbol, prepare data for it
          symbol_type          = body
          symbol_documentation = clean_comments(current_comments).join("\n")

          current_comments     = []
        elsif (name == :on_const or name == :on_ident) and symbol_type and symbol_documentation != ''
          # found the class/method name, finalize the InlineDoc
          symbol_name = body
          docs << InlineDoc.new(symbol_name, symbol_type, symbol_documentation)

          symbol_type          = nil
          symbol_name          = nil
          symbol_documentation = nil
        end
      end

      docs
    end

    private

    def clean_comments(lines)
      return [] if lines.empty?

      regex_pattern = /^\s*#\s*/
      prefix_length = lines.first[regex_pattern].length
      lines.map { |line| line[prefix_length, line.length].rstrip }
    end
  end
end
