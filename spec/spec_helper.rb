require 'rubygems'
require 'spec'
require 'pp'

require File.dirname(__FILE__) + '/../lib/gem_resolver'

module GemResolver
  module SourceIndexHacks
    def to_dsl
      content = ""
      content << "@index = build_index do\n"
      each do |name,spec|
        content << '  add_spec "%s", "%s"' % [spec.name, spec.version]
        deps = spec.runtime_dependencies
        if deps.any?
          content << " do\n"
          deps.each do |dep|
            reqs = dep.version_requirements.requirements.map {|r| r.to_s}.inspect
            content << "    runtime \"%s\", %s\n" % [dep.name, reqs]
          end
          content << "  end"
        end
        content << "\n"
      end
      content << "end\n"
      content
    end
  end
end

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
