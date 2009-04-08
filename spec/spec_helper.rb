require 'rubygems'
require 'spec'
require 'pp'

require File.dirname(__FILE__) + '/../lib/gem_resolver'

Spec::Runner.configure do |config|
  config.include(GemResolver::Builders)
end

Spec::Matchers.create :contain_gems do |gems|
  match do |source_index|
    @dump = []
    source_index.gems.each do |full_name,spec|
      @dump << [spec.name.to_s, spec.version.to_s]
    end
    @dump.sort == gems.sort
  end

  failure_message_for_should do |source_index|
    "The source index was expected to have the gems #{gems.sort.inspect}, but got #{@dump.sort.inspect}"
  end
end

Spec::Matchers.create :match_gems do |expected|
  match do |actual|
    @_messages = []
    unless expected.size == actual.size
      @_messages << "Expected there to be #{expected.size} gems in #{actual.inspect}, but got #{actual.size}"
      next false
    end

    @dump = []
    actual.each do |spec|
      unless spec.is_a?(Gem::Specification)
        @_messages << "#{spec.inspect} was expected to be a Gem::Specification"
        next
      end
      @dump << [spec.name.to_s, spec.version.to_s]
    end

    if @_messages.any?
      @_messages.unshift "The gems #{actual.inspect} were not structured as expected. "
      next false
    end

    unless @dump.sort == expected.sort
      @_messages << "The source index was expected to have the gems #{actual.sort.inspect}, but got #{@dump.sort.inspect}"
      next false
    end
    true
  end

  failure_message_for_should do |actual|
    @_messages.join("\n")
  end
end
