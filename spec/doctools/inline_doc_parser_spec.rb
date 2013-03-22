require 'spec_helper'
require 'doctools/inline_doc_parser'

module Doctools
  describe InlineDocParser do
    let(:test_string) do
      normalize_string_indent(<<-EOF)
        # This is a test class to
        # play around with
        class Foo < Bar
          def undocumented
          end

          # This is a test function to play around with
          def bar
            'baz'
          end
        end
      EOF
    end

    it "parses a given test file into InlineDoc objects" do
      class_doc, method_doc = InlineDocParser.new(test_string).parse

      class_doc.symbol.should eq 'Foo'
      class_doc.type.should eq 'class'
      class_doc.documentation.should eq normalize_string_indent(<<-EOF)
        This is a test class to
        play around with
      EOF

      method_doc.symbol.should eq 'bar'
      method_doc.type.should eq 'def'
      method_doc.documentation.should eq normalize_string_indent(<<-EOF)
        This is a test function to play around with
      EOF
    end
  end
end
