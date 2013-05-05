require 'pathname'
require 'doctools/repo'

module Doctools
  # TODO (2013-05-05) Currently not very usable, WIP
  class Cli
    def initialize(root, args)
      @root = Pathname.new(root)
      @args = args
    end

    def run
      subcommand = @args.shift

      case subcommand
      when 'sync'
        sync(@args.first)
      end
    end

    # TODO (2013-05-05) Different origin, branch
    def sync(project_description)
      username, project_name = project_description.split('/')
      repo = Repo.new(project_name, username, project_name, 'master')
      project_directory = @root.join(project_description)

      if File.directory?(project_directory)
        FileUtils.cd(project_directory) do
          sh 'git fetch origin && git reset --hard origin/master'
        end
      else
        FileUtils.mkdir_p(project_directory)
        sh "git clone https://github.com/#{project_description} #{project_directory}"
      end
    end

    private

    # stubbable, potentially replaceable with something cleverer
    def sh(*args)
      system(*args)
    end
  end
end
