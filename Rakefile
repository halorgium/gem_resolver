require 'rake/gempackagetask'
require File.dirname(__FILE__) + '/lib/gem_resolver/version'

spec = Gem::Specification.new do |s|
  s.name = "gem_resolver"
  s.version = GemResolver::VERSION

  s.author = "Tim Carey-Smith"
  s.email = "tim@spork.in"
  s.date = Date.today.to_s
  s.description = "gem_resolver determines the specs for some gem deps"
  s.summary = s.description
  s.homepage = "http://github.com/halorgium/gem_resolver"

  s.require_paths = ["lib"]

  s.files = Dir["lib/**/*.rb"]
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end
