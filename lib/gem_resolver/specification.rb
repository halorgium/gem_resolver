class Gem::Specification
  def resolved_dependencies_in(source_index)
    GemResolver::Engine.search_for(@dependencies, source_index)
  end
end
