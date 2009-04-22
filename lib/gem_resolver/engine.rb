module GemResolver
  class ClosedSet < Set
    def include?(state)
      match = nil
      self.any? do |s|
        state == s && match = s
      end
      if match
        state.logger.warn "already includes #{state.path.inspect} at #{match.path.inspect}"
        match.logger.warn "existing"
        match.dump(Logger::WARN)
        state.logger.warn "new"
        state.dump(Logger::WARN)
      end
    end
  end

  class Engine
    include DepthFirstSearch

    def self.resolve(deps, source_index, logger)
      new(deps, source_index, logger).resolve
    end

    def initialize(deps, source_index, logger)
      @deps, @source_index, @logger = deps, source_index, logger
      logger.debug "searching for #{@deps.gem_resolver_inspect}"
    end
    attr_reader :deps, :source_index, :logger, :solution

    def resolve
      state = State.initial(self, [], Stack.new, Stack.new([[[], @deps.dup]]))
      solution = search(state)
      logger.info "got the solution with #{solution.all_specs.size} specs"
      solution.dump(Logger::INFO)
      solution
    end

    def open
      @open ||= []
    end

    def closed
      @closed ||= ClosedSet.new
    end
  end
end
