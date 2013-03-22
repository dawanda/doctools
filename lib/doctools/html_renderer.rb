require 'doctools/autolinker'
require 'doctools/graph_renderer'
require 'doctools/sinatra_parser'

module Doctools
  # Used to do some additional processing while parsing the markdown. Currently
  # it does the following:
  #
  # - Inspects inline code blocks and attempts to turn them into github links.
  # - Turns specially-formatted links into relationship graphs
  #
  # TODO (2013-03-22) Hacky `super` implementation, perhaps there's a better way?
  #
  class HtmlRenderer < Redcarpet::Render::HTML
    attr_reader :repo

    def initialize(options = {})
      @repo         = options.delete(:repo)
      @linker       = Autolinker.new(repo)
      @list_started = false
      @graph_items  = []
      @super        = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(options))

      super(options)
    end

    def codespan(code)
      try_link(code)
    end

    def list_item(text, list_type)
      text = text.strip

      if text == '+' and not @list_started
        @list_started = true
        nil
      elsif text == '+' and @list_started
        @list_started = false
        render_graph
      elsif @list_started
        @graph_items << text
        "<li>#{text}</li>\n"
      else
        "<li>#{text}</li>\n"
      end
    end

    private

    def original_block_code(code, language)
      @super.render("``` #{language}\n#{code}```")
    end

    def render_graph
      image = GraphRenderer.new(@graph_items).render
      @graph_items = []

      <<-HTML
        <a href="javascript://" class="graph-trigger">Pretty graph</a>
        <div class="graph-wrapper">
          <img class="graph" src="data:image/png;base64,#{image}" />
        </div>
      HTML
    end

    def try_link(text)
      @linker.link(text)
    end
  end
end
