$: << File.expand_path(File.dirname(__FILE__) + '/lib')

desc "Build markdown files for rendering"
task :build do
  require 'fileutils'
  require 'doctools/repo'
  require 'doctools/markdown_includer'

  config = Doctools::Config.new

  Doctools::Repo.all.each do |name, repo|
    repo.cd do
      markdown = Doctools::MarkdownIncluder.new(IO.read('README.md')).process
      File.open(config.expand_path("processed/#{name}.md"), 'w') do |f|
        f.write(markdown)
      end

      %x[ctags -R]
    end
  end
end
