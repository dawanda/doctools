require 'spec_helper'
require 'doctools/autolinker'

module Doctools
  describe Autolinker do
    let(:repo)   { stub(:name => 'name', :url => 'url', :expand_path => 'stub') }
    let(:linker) { Autolinker.new(repo) }

    it "wraps file and directory paths with links" do
      pending "Need to setup proper filesystem stubs (or test repo object?)"

      linker.link('app/models/user.rb').start_with?('<a').should be_true
      linker.link('user.rb').start_with?('<a').should be_true
      linker.link('app/models/').start_with?('<a').should be_true
    end

    it "wraps class and method names with links" do
      pending "Need to setup proper ctags stubs"

      linker.link('User').start_with?('<a').should be_true
      linker.link('get_data').start_with?('<a').should be_true
      linker.link('Doc::Autolinker').start_with?('<a').should be_true
    end

    it "ignores uninteresting code blocks" do
      linker.link('one two').start_with?('<a').should be_false
      linker.link('key: value').start_with?('<a').should be_false
      linker.link('[1, 2, 3]').start_with?('<a').should be_false
    end

    it "doesn't crash without a repo" do
      linker = Autolinker.new(nil)
      linker.link('app/models/user.rb').should eq '<code>app/models/user.rb</code>'
    end
  end
end
