require 'fileutils'
require 'doctools/config'

module Doctools
  # A single result from running a grep query. This is instantiated from a
  # Doctools::Grep, though you could just give it a set of lines that are
  # formatted in that way and it should handle parsing them.
  #
  # The parsing is run on-demand, since with its current use-case, parsing
  # every result upon instantiation is really not needed.
  class GrepResult
    def initialize(lines)
      @raw_lines = lines
      @lines     = nil
    end

    def filename    ; process ; @filename    ; end
    def start_line  ; process ; @start_line  ; end
    def end_line    ; process ; @end_line    ; end
    def middle_line ; process ; @middle_line ; end
    def lines       ; process ; @lines       ; end

    def formatted_filename
      filename.gsub(/^target\/\.repos\//, '')
    end

    private

    # Processes each line of the result. Assumes the format is something like this:
    #
    #   path/file.js-1811-  function frooble() {
    #   path/file.js:1812:    // TODO: Frobble
    #   path/file.js-1813-  }
    #
    def process
      return if @lines

      @filename    = find_filename(@raw_lines)
      @lines       = []
      line_numbers = []

      @raw_lines.each do |raw_line|
        # slice off the filename:
        line = raw_line[@filename.length, raw_line.length - 1]

        # slice off the line number:
        if line =~ /^-(\d+)-(.*)$/
          line_number = $1.to_i
          line        = $2
        elsif line =~ /^:(\d+):(.*)$/
          line_number  = $1.to_i
          line         = $2
          @middle_line = line_number
        else
          raise "Unexpected format of line: '#{line}' (raw: '#{raw_line}')"
        end

        @lines << line
        line_numbers << line_number
      end

      @start_line = line_numbers.min
      @end_line   = line_numbers.max
    end

    # Attempts to find the common filename of the collection of lines by
    # grabbing the first line, iterating by character and stopping when
    # something of the form "-42-" or ":42:" is reached, which is Ack's way to
    # denote the line of the file.
    #
    def find_filename(lines)
      first_line      = lines.first
      end_of_filename = first_line.length - 1

      (0 .. first_line.length).each do |index|
        if first_line[index, first_line.length] =~ /^[-:]\d+[-:]/
          end_of_filename = index
          break
        end
      end

      first_line[0, end_of_filename]
    end
  end
end
