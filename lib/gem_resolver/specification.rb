class Gem::Specification
  def resolved_dependencies_in(source_index)
    GemResolver::Attempt.run(nil, self, source_index)
  end

  def gem_resolver_inspect
    to_s
  end
end
