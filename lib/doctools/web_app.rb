require 'erubis'
require 'sinatra/base'
require 'doctools/repo'
require 'doctools/renderer'
require 'doctools/markdown_splitter'

module Doctools
  class WebApp < Sinatra::Base
    set :views,         File.join(Config.new.basedir, 'web/views')
    set :public_folder, File.join(Config.new.basedir, 'web/public')
    set :environment,   :test
    set :raise_errors,  true
    set :erubis,        :escape_html => true

    get '/api/*' do
      path     = params[:splat].first
      markdown = IO.read("processed/#{path}.md")

      MarkdownSplitter.new(markdown).section(params[:section])
    end

    get '/*' do
      path = params[:splat].first

      if path == ''
        path = 'index'
        repo = nil
      else
        repo = repos[path]
      end

      erb Renderer.new(:repo => repo).run("processed/#{path}.md")
    end

    private

    def repos
      @repos ||= Repo.all
    end
  end
end
