class Gem::Dependency
  def matching_specs_in(source_index)
    source_index.search(self)
  end

  def gem_resolver_inspect
    to_s
  end
end

