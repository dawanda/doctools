require 'graphviz'
require 'tempfile'
require 'base64'

module Doctools
  # Takes a list of items and turns it into a relationship graph using
  # GraphViz. Implementation is so far fairly naive, regarding pluralization
  # for example. Could use some love.
  #
  class GraphRenderer
    def initialize(items)
      @items = items
    end

    def render
      graph = GraphViz.new(:G, :type => :digraph)

      @items.each do |line|
        if line =~ /(\w+) has one (\w+)/
          graph.add_edges($1, $2, :label => '1')
        elsif line =~ /(\w+) has many (\w+)s/
          graph.add_edges($1, $2, :label => 'N')
        end
      end

      image = nil
      Tempfile.open('graph') do |file|
        graph.output(:png => file.path)
        image = Base64.encode64(IO.read(file.path)).gsub("\n", '')
      end
      image
    end
  end
end
