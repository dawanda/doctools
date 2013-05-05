require 'fileutils'
require 'doctools/config'

module Doctools
  # Provides information on a Github repo and its contents. The entries are
  # generated from data from the file config.yml. The ::all method provides a
  # shortcut to get all repos defined in the config file as a hash with entries
  # of the form:
  #
  #   :repo_name => repo_object
  #
  # TODO (2013-05-05) Use branch as an option, remove name
  class Repo
    def self.all
      repos = {}
      Config.new.repos.map do |name, data|
        username, project, branch = data.split('#')
        repos[name] = Doctools::Repo.new(name, username, project, branch)
      end
      repos
    end

    attr_reader :name, :github_username, :github_project, :branch

    def initialize(name, github_username, github_project, branch)
      @name            = name
      @github_username = github_username
      @github_project  = github_project
      @branch          = branch
    end

    def expand_path(filename)
      config.expand_path("repos/#{name}/#{filename}")
    end

    def cd
      FileUtils.cd(expand_path('')) do
        yield
      end
    end

    # Options:
    #
    #   - filename: A file to link to, relative to the repo url
    #   - line:     The line number to link to. Only works with :filename
    #
    def url(options = {})
      url = "https://github.com/#{github_username}/#{github_project}"

      if options[:filename]
        url = "#{url}/blob/#{branch}/#{options[:filename]}"
      end

      if options[:filename] && options[:line]
        url = "#{url}#L#{options[:line]}"
      end

      url
    end

    private

    def config
      @config ||= Doctools::Config.new
    end
  end
end
