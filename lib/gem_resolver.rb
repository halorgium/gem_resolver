$:.unshift File.dirname(__FILE__)
require 'depth_first_search'
require 'logger'

require 'gem_resolver/stack'
require 'gem_resolver/engine'
require 'gem_resolver/state'
require 'gem_resolver/builders'
require 'gem_resolver/inspects'

module GemResolver
  def self.resolve(deps, source_index = Gem.source_index, logger = nil)
    logger = Logger.new($stderr)
    logger.datetime_format = ""
    logger.level = if ENV["GEM_RESOLVER_DEBUG"]
                     Logger::DEBUG
                   else
                     Logger::WARN
                   end
    Engine.resolve(deps, source_index, logger).all_specs
  end
end
