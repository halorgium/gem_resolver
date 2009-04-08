module GemResolver
  class DependencyHolder
    def initialize(dependencies)
      @dependencies = dependencies.map {|x| Gem::Dependency.new(*x)}
    end
    attr_reader :dependencies

    def runtime_dependencies
      @dependencies.select {|x| x.type == :runtime}
    end

    def development_dependencies
      @dependencies.select {|x| x.type == :development}
    end

    def resolved_dependencies_in(source_index)
      Attempt.run(nil, self, source_index)
    end
  end
end
