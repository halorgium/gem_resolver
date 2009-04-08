class Gem::Specification
  def resolved_dependencies_in(source_index)
    GemResolver::Engine.search_for(@dependencies, source_index)
  end

  def gem_resolver_inspect
    to_s
  end
end
