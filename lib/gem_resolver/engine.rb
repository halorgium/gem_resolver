module GemResolver
  class ClosedSet < Set
  end

  class Engine
    include DepthFirstSearch

    def self.resolve(dependency_types, deps, source_index, logger)
      new(dependency_types, deps, source_index, logger).resolve
    end

    def initialize(dependency_types, deps, source_index, logger)
      @dependency_types, @deps, @source_index, @logger = dependency_types, deps, source_index, logger
      logger.debug "searching for #{@deps.gem_resolver_inspect}"
    end
    attr_reader :dependency_types, :deps, :source_index, :logger, :solution

    def resolve
      state = State.initial(self, [], Stack.new, Stack.new([[[], @deps.dup]]))
      if solution = search(state)
        logger.info "got the solution with #{solution.all_specs.size} specs"
        solution.dump(Logger::INFO)
        solution
      end
    end

    def open
      @open ||= []
    end

    def closed
      @closed ||= ClosedSet.new
    end
  end
end
