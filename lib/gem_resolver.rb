$:.unshift File.dirname(__FILE__)

require 'gem_resolver/engine'
require 'gem_resolver/state'
require 'gem_resolver/attempt'

require 'set'
require 'logger'

module GemResolver
  class Error < StandardError; end
  class BadDep < Error
    def initialize(*deps)
      @deps = deps
      super("Couldn't satisfy dependencies: #{@deps.map {|x| "'#{x.to_s}'"}.join(', ')}")
    end
    attr_reader :deps

    def latest_dep
      @deps.first
    end
  end

  def self.resolve(dependencies, source_index, logger = Logger.new($stderr, Logger::DEBUG))
    Engine.resolve(dependencies, source_index, logger)
  end
end
