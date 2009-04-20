module GemResolver
  class State
    include DepthFirstSearch::Node

    def initialize(depth, engine, path, spec_stack, dep_stack)
      super(depth)
      @engine, @path, @spec_stack, @dep_stack = engine, path, spec_stack, dep_stack
    end

    def logger
      @engine.logger
    end

    def goal_met?
      logger.debug "checking if goal is met"
      dump
      all_deps.all? do |dep|
        all_specs.any? do |spec|
          spec.satisfies_requirement?(dep)
        end
      end
    end

    def each_possibility
      logger.debug "getting possibilities"
      dump
      index, dep = remaining_deps.first

      unless dep
        logger.debug "Ending"
        new_path = @path[0..-2]
        new_spec_stack = @spec_stack.dup
        new_dep_stack = @dep_stack.dup

        yield child(@engine, new_path, new_spec_stack, new_dep_stack)
        return
      end

      logger.debug "working on #{dep}"
      @engine.source_index.search(dep).reverse.each do |spec|
        logger.debug "got a spec: #{spec.full_name}"
        new_path = @path + [index]
        new_spec_stack = @spec_stack.dup
        new_dep_stack = @dep_stack.dup

        new_spec_stack[new_path] = spec
        new_dep_stack[new_path] = spec.runtime_dependencies
        yield child(@engine, new_path, new_spec_stack, new_dep_stack)
      end
    end

    def remaining_deps
      remaining_deps_for(@path)
    end

    def remaining_deps_for(path)
      remaining = []
      @dep_stack[path].each_with_index do |dep,i|
        remaining << [i, dep] unless @spec_stack.key?(path + [i])
      end
      remaining
    end

    def deps
      @dep_stack[@path]
    end

    def all_deps
      all_deps = Set.new
      @dep_stack.each_value do |deps|
        all_deps.merge(deps)
      end
      all_deps.to_a
    end

    def all_specs
      @spec_stack.map do |path,spec|
        spec
      end
    end

    def dump
      logger.debug "v" * 80
      logger.debug "path: #{@path.inspect}"
      logger.debug "deps: (#{deps.size})"
      deps.map do |dep|
        logger.debug dep.gem_resolver_inspect
      end
      logger.debug "remaining_deps: (#{remaining_deps.size})"
      remaining_deps.each do |dep|
        logger.debug dep.gem_resolver_inspect
      end
      logger.debug "dep_stack: "
      @dep_stack.each do |path,deps|
        logger.debug "#{path.inspect} (#{deps.size})"
        deps.each do |dep|
          logger.debug "-> #{dep.gem_resolver_inspect}"
        end
      end
      logger.debug "spec_stack: "
      @spec_stack.each do |path,spec|
        logger.debug "#{path.inspect}: #{spec.gem_resolver_inspect}"
      end
      logger.debug "^" * 80
    end
  end
end
