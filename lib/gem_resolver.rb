$:.unshift File.dirname(__FILE__)

require 'gem_resolver/builders'
require 'gem_resolver/specification'
require 'gem_resolver/dependency'
require 'gem_resolver/engine'

class Array
  def gem_resolver_inspect
    '[' + map {|x| x.gem_resolver_inspect}.join(", ") + ']'
  end
end
