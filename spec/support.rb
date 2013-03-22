module SpecSupport
  # Normalizes a string's indentation whitespace, so that heredocs can be used
  # more easily for testing.
  #
  # Example
  #
  #   foo = normalize_string_indent(<<-EOF)
  #     def foo
  #       bar
  #     end
  #   EOF
  #
  # In this case, the raw string would have a large chunk of indentation in
  # the beginning due to its location within the code. The helper removes all
  # whitespace in the beginning by taking the one of the first line.
  #
  # Note: #scan and #chop are being used instead of #split to avoid
  # discarding empty lines.
  def normalize_string_indent(string)
    if string.end_with?("\n")
      lines = string.scan(/.*\n/).map(&:chop)
      whitespace = lines.grep(/\S/).first.scan(/^\s*/).first
    else
      lines = [string]
      whitespace = string.scan(/^\s*/).first
    end

    lines.map do |line|
      line.gsub(/^#{whitespace}/, '') if line =~ /\S/
    end.join("\n")
  end
end
