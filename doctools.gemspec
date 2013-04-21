require File.expand_path('../lib/doctools/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'doctools'
  s.authors     = ['Andrew Radev', 'Paul Asmuth']
  s.version     = Doctools::VERSION
  s.summary     = "A tool to help with reading and writing documentation"
  s.description = <<-EOF
    The doctools gem is a simple tool that can checkout projects from github
    and serve their READMEs similarly to how github does it. However, it also
    does some additional processing that might make it useful for internal
    projects that you have control over.
  EOF

  s.files       = Dir['lib/**/*.rb', 'vim/*', 'bin/*', 'LICENSE', '*.md']
  s.homepage    = 'http://github.com/dawanda/doctools'
  s.executables = ['doctools']
end
