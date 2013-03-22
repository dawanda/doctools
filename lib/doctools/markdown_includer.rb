require 'doctools/sinatra_parser'

module Doctools
  # This class preprocesses markdown to replace calls to a made up "include"
  # helper with appropriate results. Currently it processes the following types
  # of @include:
  #
  #   @include rake-tasks            #=> Includes the output of rake -T
  #   @include sinatra(file/name.rb) #=> Includes sinatra endpoints parsed from the given file
  #
  class MarkdownIncluder
    def initialize(text)
      @text   = text
      @output = text
    end

    def process
      include_rake_tasks
      include_sinatra

      @output
    end

    private

    def include_rake_tasks
      @output = @output.gsub(/^([ \t]*)@include rake-tasks/) do
        indent = $1
        %x[rake -T].
          split("\n").
          map { |line| line.strip.gsub(/^\s*/, indent) }.
          join("\n")
      end
    end

    def include_sinatra
      @output = @output.gsub(/^([ \t]*)@include sinatra\((.*?)\)/) do
        indent   = $1
        filename = $2

        SinatraParser.new(IO.read(filename)).lines.map do |line|
          line.strip.
            gsub(/^\s*/, indent).
            gsub(/do\s*(|.*|)\s*$/, '')
        end.join("\n")
      end
    end
  end
end
