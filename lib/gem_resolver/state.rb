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

    def dump
      logger.debug "v" * 80
      logger.debug "path: #{@path.inspect}"
      logger.debug "deps: #{deps.gem_resolver_inspect}"
      logger.debug "remaining_deps: #{remaining_deps.gem_resolver_inspect}"
      logger.debug "dep_stack: #{@dep_stack.gem_resolver_inspect}"
      logger.debug "spec_stack: #{@spec_stack.gem_resolver_inspect}"
      logger.debug "^" * 80
    end

    def each_possibility
      logger.debug "getting possibilities"
      dump
      index, dep = remaining_deps.first

      unless dep
        yield self
        return
      end

      logger.debug "working on #{dep}"
      @engine.source_index.search(dep).each do |spec|
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
      @dep_stack.last
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
  end
end
