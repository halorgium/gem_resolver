require 'rubygems'
require 'spec'
require 'pp'

require File.dirname(__FILE__) + '/../lib/gem_resolver'

require 'gem_resolver/builders'

Spec::Runner.configure do |config|
  config.include(GemResolver::Builders)
end

Spec::Matchers.create :match_gems do |expected|
  match do |actual|
    @_messages = []
    @dump = {}

    if actual.nil?
      @_messages << "The result is nil"
      next
    end

    actual.each do |spec|
      unless spec.is_a?(Gem::Specification)
        @_messages << "#{spec.gem_resolver_inspect} was expected to be a Gem::Specification, but got #{spec.class}"
        next
      end
      @dump[spec.name.to_s] ||= []
      @dump[spec.name.to_s] << spec.version.to_s
    end

    if @_messages.any?
      @_messages.unshift "The gems #{actual.gem_resolver_inspect} were not structured as expected"
      next false
    end

    unless @dump == expected
      @_messages << "The source index was expected to have the gems #{expected.inspect}, but got #{@dump.inspect}"
      next false
    end
    true
  end

  failure_message_for_should do |actual|
    @_messages.join("\n")
  end
end

class Object
  def gem_resolver_inspect
    inspect
  end
end

class Gem::Specification
  def gem_resolver_inspect
    to_s
  end
end

class Gem::Dependency
  def gem_resolver_inspect
    to_s
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
