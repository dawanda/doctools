require 'tmpdir'
require 'pathname'
require 'fileutils'
require 'spec_helper'
require 'doctools/cli'

module Doctools
  describe Cli do
    around do |example|
      Dir.mktmpdir do |dir|
        FileUtils.cd(dir) do
          example.run
        end
      end
    end

    # TODO (2013-05-05) Instantiate Repo with a username and project name
    # TODO (2013-05-05) Set up the Cli object's root directory
    # TODO (2013-05-05) Filter out online tests by default? How to ensure they're stull run?
    describe "sync" do
      def pathname(*args)
        Pathname.new(*args)
      end

      it "checks out a github project", :online => true do
        Cli.new('.', ['sync', 'dawanda/doctools']).run
        pathname('dawanda/doctools').should be_directory
        pathname('dawanda/doctools/.git').should be_directory
        pathname('dawanda/doctools/README.md').should be_file
      end

      it "maintains a github project in sync", :online => true do
        Cli.new('.', ['sync', 'dawanda/doctools']).run
        FileUtils.rm 'dawanda/doctools/README.md'
        Cli.new('.', ['sync', 'dawanda/doctools']).run
        pathname('dawanda/doctools/README.md').should be_file
      end
    end
  end
end
