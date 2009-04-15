$:.unshift File.dirname(__FILE__)

require 'gem_resolver/engine'

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

  def self.resolve(dependencies, source_index = Gem.source_index, logger = nil)
    logger = Logger.new($stderr)
    logger.level = if ENV["GEM_RESOLVER_DEBUG"]
                     Logger::DEBUG
                   else
                     Logger::WARN
                   end
    Engine.resolve(dependencies, source_index, logger)
  end
end
