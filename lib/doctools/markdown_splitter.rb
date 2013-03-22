module Doctools
  # Can extract a single section from the given markdown text. Assumes that a
  # "section" is a markdown-style h2.
  #
  class MarkdownSplitter
    attr_reader :text

    def initialize(text)
      @text = text
    end

    def section(section_name)
      # if no section was given, just return the whole thing
      return text if not section_name or section_name.strip == ''
      section_name = section_name.strip

      lines = @text.lines

      # Drop anything before the given section
      lines = lines.drop_while do |line|
        line !~ /^##\s+#{section_name}/i
      end

      if lines.empty?
        # nothing was found, return nothing
        return ''
      end

      # Only take lines before the next section
      lines = [lines.first] + lines[1, lines.length].take_while do |line|
        line !~ /^##\s+\w/i
      end

      compress_blank_lines(lines).join
    end

    private

    def compress_blank_lines(lines)
      compressed_lines = []

      lines.each do |line|
        if line =~ /^\s*$/ and compressed_lines.last =~ /^\s*$/
          # we already have a blank line, don't add a second one
        else
          compressed_lines << line
        end
      end

      compressed_lines
    end
  end
end
