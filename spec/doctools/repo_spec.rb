require 'spec_helper'
require 'doctools/repo'

module Doctools
  describe Repo do
    pending 'Implement proper url parsing'

    let(:repo) { Repo.new('vimrunner', 'git://github.com/AndrewRadev/vimrunner.git', 'master') }

    it "knows its name" do
      repo.name.should eq 'vimrunner'
      repo.github_project.should eq 'vimrunner'
    end

    describe "#url" do
      it "returns the link to the github repo if given no arguments" do
        repo.url.should eq 'https://github.com/AndrewRadev/vimrunner'
      end

      it "returns a link to the file at the given branch if given a filename" do
        repo.url(:filename => 'bin/vimrunner').should eq 'https://github.com/AndrewRadev/vimrunner/blob/master/bin/vimrunner'
      end

      it "returns a link to the file at the given branch with the given line number if given a linenumber" do
        repo.url({
          :filename => 'bin/vimrunner',
          :line     => 6,
        }).should eq 'https://github.com/AndrewRadev/vimrunner/blob/master/bin/vimrunner#L6'
      end
    end
  end
end
