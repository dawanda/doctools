require 'doctools/config'

module Doctools
  # Provides information on a Github repo and its contents. The entries are
  # generated from data from the file config.yml. The ::all method provides a
  # shortcut to get all repos defined in the config file as a hash with entries
  # of the form:
  #
  #   :repo_name => repo_object
  #
  class Repo
    def self.all
      repos = {}
      Config.new.repos.map do |name, data|
        ssh_url, branch = data.split('#')
        repos[name] = Doc::Repo.new(name, ssh_url, branch)
      end
      repos
    end

    attr_reader :name, :branch

    def initialize(name, ssh_url, branch)
      @name    = name
      @ssh_url = ssh_url
      @branch  = branch
    end

    # TODO (2013-03-22) Multiple variants of github urls
    def github_name
      @github_name ||= @ssh_url.gsub(/^git:\/\/github.com\/(.*?)\/(.+?)\.git$/, '\2')
    end

    # TODO (2013-03-22) Configurable?
    def expand_path(filename)
      config.expand_path("target/.repos/#{@name}/#{filename}")
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
    # TODO (2013-03-22) Generate url from username, repo
    def url(options = {})
      url = "TODO://#{github_name}"

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
