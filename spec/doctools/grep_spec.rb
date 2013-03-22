require 'spec_helper'
require 'doctools/grep'

module Doctools
  describe Grep do
    let(:raw_output) do
      <<-EOF
        repos/jquery.js-1811-
        repos/jquery.js:1812:         // TODO: Move to normal caching system
        repos/jquery.js-1813-         match[0] = done++;
        --
        repos/lib/jspec.js-251-    run : function() {
        repos/lib/jspec.js:252:      // TODO: remove unshifting
        repos/lib/jspec.js-253-      expected.unshift(actual)
      EOF
    end
    let(:grep) { Grep.from_results(raw_output) }

    it "splits the output by --" do
      grep_results = grep.run
      grep_results.should have(2).items
    end

    describe GrepResult do
      it "knows a set of characteristics of the result" do
        result = grep.run.first

        result.filename.should eq 'repos/jquery.js'
        result.start_line.should eq 1811
        result.middle_line.should eq 1812
        result.end_line.should eq 1813

        result.lines.map(&:strip).should eq [
          '',
          '// TODO: Move to normal caching system',
          'match[0] = done++;',
        ]
      end
    end
  end
end
