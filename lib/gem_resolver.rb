$:.unshift File.dirname(__FILE__)

require 'gem_resolver/builders'
require 'gem_resolver/specification'
require 'gem_resolver/dependency'
require 'gem_resolver/state'
require 'gem_resolver/attempt'

require 'set'

module GemResolver
  class Error < StandardError; end
  class UnableToSatifyDep < Error; end
  class SpecError < Error
    def initialize(spec, message)
      @spec = spec
      super(message)
    end
    attr_reader :spec
  end
  class BadSpec < SpecError
    def initialize(spec)
      super(spec, "Bad spec: #{spec.gem_resolver_inspect}")
    end
  end
  class Reactivation < SpecError
    def initialize(spec, existing_spec)
      super(existing_spec, "Tried to activate #{spec.full_name}, but #{existing_spec.full_name} is already activated")
    end
  end
end

class Array
  def gem_resolver_inspect
    '[' + map {|x| x.gem_resolver_inspect}.join(", ") + ']'
  end
end

class Set
  def gem_resolver_inspect
    to_a.gem_resolver_inspect
  end
end

class Hash
  def gem_resolver_inspect
    '{' + map {|k,v| "#{k.gem_resolver_inspect} => #{v.gem_resolver_inspect}"}.join(", ") + '}'
  end
end

class String
  def gem_resolver_inspect
    inspect
  end
end
