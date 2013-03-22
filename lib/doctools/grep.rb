require 'fileutils'
require 'doctools/config'
require 'doctools/grep_result'

module Doctools
  # Provides an interface to the results of a grep query. Actually uses `ack`
  # under the hood. Can be run with a query to look for, or with the results,
  # so they can be cached to a file and then just loaded in an object for
  # processing.
  #
  # It's recommended that .new is not called directly, but instead you use
  # either .from_results or .from_query to get a new object.
  #
  class Grep
    def self.from_results(results, options = {})
      new(options.merge(:results => results))
    end

    def self.from_query(query, options = {})
      new(options.merge(:query => query))
    end

    def initialize(options = {})
      @query   = options[:query]
      @results = options[:results]
      @context = options[:context] || 5

      if not @query and not @results
        raise "Neither :query, nor :results were given to work with"
      end
    end

    def run
      @run ||= parse(run_raw)
    end

    def run_raw
      return @results if @results

      if not executable_exists?
        puts "No `ack` executable found."
        return []
      end

      # TODO (2013-03-22) This probably needs to be configurable
      FileUtils.cd(config.expand_path('target/.repos')) do
        command = "ack #{@query} -C#{@context} --type=ruby --ignore-dirs=vendor"
        @results = run_shell(command)
      end

      @results
    end

    private

    def config
      @config ||= Config.new
    end

    def executable_exists?
      return system('which ack > /dev/null')
    end

    def run_shell(command)
      IO.popen(command) { |io| io.read.strip }
    end

    def parse(blob)
      results              = []
      current_result_lines = []

      blob.each_line do |line|
        line = line.strip

        if line == '--'
          results << GrepResult.new(current_result_lines)
          current_result_lines = []
        else
          current_result_lines << line
        end
      end

      # Don't forget the last result
      results << GrepResult.new(current_result_lines)

      results
    end
  end
end
