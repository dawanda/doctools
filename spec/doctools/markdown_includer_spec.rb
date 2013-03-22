require 'tmpdir'
require 'fileutils'
require 'spec_helper'
require 'doctools/markdown_includer'

module Doctools
  describe MarkdownIncluder do
    around do |example|
      Dir.mktmpdir do |dir|
        FileUtils.cd(dir) do
          example.run
        end
      end
    end

    def write_file(filename, string)
      FileUtils.mkdir_p(File.dirname(filename))
      File.open(filename, 'w') { |f| f.write(string) }
    end

    def process(text)
      MarkdownIncluder.new(text).process
    end

    it "includes rake tasks in the markdown text" do
      write_file 'Rakefile', <<-EOF
        desc "Some task"
        task :some do
          something
        end

        desc "Some other task"
        task :other do
          something_else
        end
      EOF

      output = process(<<-EOF)
        one
          @include rake-tasks
        two
      EOF

      output.should =~ /some\s+# Some task/
      output.should =~ /other\s+# Some other task/
    end

    it "includes sinatra endpoints in the markdown text" do
      write_file 'lib/test.rb', <<-EOF
        get '/' do
        end

        post '/one/:id' do
        end
      EOF

      output = process(<<-EOF)
        one
          @include sinatra(lib/test.rb)
        two
      EOF

      output.should =~ /get '\/'/
      output.should =~ /post '\/one\/:id'/
    end
  end
end
