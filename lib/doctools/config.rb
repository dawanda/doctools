require 'yaml'
require 'pathname'

module Doctools
  # Provides an interface to the configuration of the project, including paths,
  # repo urls and so on.
  #
  class Config
    def basedir
      @basedir ||= Pathname.new(File.expand_path('../../../', __FILE__))
    end

    def repos
      data['repos']
    end

    def expand_path(*path)
      basedir.join(*path)
    end

    def sitemap_file
      expand_path('target/sitemap.yml')
    end

    def get_sitemap_data
      YAML.load(IO.read(sitemap_file))
    end

    private

    def data
      @data ||= YAML.load(IO.read(expand_path('config.yml')))
    end
  end
end
