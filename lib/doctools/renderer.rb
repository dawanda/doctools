require 'redcarpet'
require 'digest/md5'
require 'doctools/config'
require 'doctools/html_renderer'

module Doctools
  # Used to parse markdown files. The main entry point is the #run method,
  # which receives the path to a markdown file and returns the resulting HTML.
  #
  class Renderer
    def initialize(options = {})
      @options = options
    end

    def run(path)
      markdown.render(IO.read(config.expand_path(path)))
    end

    private

    def config
      @config ||= Config.new
    end

    def markdown
      return @markdown if @markdown

      html_renderer = Doctools::HtmlRenderer.new({
        :with_toc_data => true,
      }.merge(@options))

      @markdown = Redcarpet::Markdown.new(html_renderer, {
        :no_intra_emphasis  => true,
        :fenced_code_blocks => true,
        :autolink           => true,
        :strikethrough      => true,
      })

      @markdown
    end
  end
end
