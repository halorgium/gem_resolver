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
      logger.info "checking if goal is met"
      dump
      all_deps.all? do |dep|
        dependency_satisfied?(dep)
      end
    end

    def dependency_satisfied?(dep)
      all_specs.any? do |spec|
        spec.satisfies_requirement?(dep)
      end
    end

    def each_possibility(&block)
      logger.info "getting possibilities"
      dump
      index, dep = remaining_deps.first

      if dep
        if dependency_satisfied?(dep)
          jump_to_parent(&block)
        else
          handle_dep(index, dep, &block)
        end
      else
        jump_to_parent(&block)
      end
    end

    def handle_dep(index, dep)
      logger.warn "working on #{dep}"
      @engine.source_index.search(dep).reverse.each do |spec|
        logger.warn "got a spec: #{spec.full_name}"
        new_path = @path + [index]
        new_spec_stack = @spec_stack.dup
        new_dep_stack = @dep_stack.dup

        new_spec_stack[new_path] = spec
        new_dep_stack[new_path] = spec.runtime_dependencies
        yield child(@engine, new_path, new_spec_stack, new_dep_stack)
      end
    end

    def jump_to_parent
      logger.info "Ending"
      new_path = @path[0..-2]
      new_spec_stack = @spec_stack.dup
      new_dep_stack = @dep_stack.dup

      yield child(@engine, new_path, new_spec_stack, new_dep_stack)
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
