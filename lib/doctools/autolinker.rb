require 'ctags_reader'
require 'doctools/config'
require 'doctools/inline_doc_parser'

module Doctools
  # This class is meant to be used by the markdown renderer. It takes care of
  # turning strings that look like significant symbols into links to their
  # locations on github. If the string doesn't look like anything interesting,
  # it's just wrapped in `<code></code>`.
  #
  # It needs a `Repo` object to work with.
  #
  class Autolinker
    attr_reader :repo

    def initialize(repo)
      @repo = repo
    end

    def link(text)
      formatted_text = "<code>#{text}</code>"

      return formatted_text if not repo
      return formatted_text if text =~ /\n/

      if entity_url = find_entity_url(text)
        title = entity_documentation(text).gsub('"', '&quot;')
        %Q[<a href="#{entity_url}" class="hint hint--top" data-hint="#{title}">#{formatted_text}</a>]
      elsif is_filename?(text)
        %Q[<a href="#{repo.url(:filename => text)}">#{formatted_text}</a>]
      else
        formatted_text
      end
    end

    private

    def entity_documentation(entity)
      tag = find_ctags_tag(entity)
      return '' if not tag

      docs = InlineDocParser.new(IO.read(repo_filename(tag.filename))).parse
      doc  = docs.find { |doc| doc.symbol == entity }

      if doc
        doc.documentation
      else
        ''
      end
    end

    def find_entity_url(name)
      return nil if name !~ /^[a-zA-Z_:]+$/
      tag = find_ctags_tag(name)
      return nil if not tag

      repo.url(:filename => tag.filename, :line => tag.line_number)
    end

    def is_filename?(text)
      return false if text !~ /^[a-zA-Z0-9\-_\/.]+$/
      return false if not text.include?('/') and not text.include?('.')
      File.exist?(repo_filename(text))
    end

    def repo_filename(filename)
      repo.expand_path(filename)
    end

    def find_ctags_tag(symbol)
      return nil if not ctags
      ctags.find(symbol)
    end

    def ctags
      return @ctags if @ctags

      if @repo
        ctags_filename = repo.expand_path("tags")
        if File.exist?(ctags_filename)
          @ctags = CtagsReader::Reader.new(ctags_filename)
        end
      end
    end

    def config
      @config ||= Config.new
    end
  end
end
