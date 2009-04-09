module GemResolver
  class State
    def self.resolve(parent, dep)
      new(parent, dep).resolve
    end

    def initialize(parent, dep)
      @parent, @dep = parent, dep
      reset
    end
    attr_reader :parent, :dep

    def resolve
      logger.debug "searching for: #{@dep}"
      if spec = candidates.first
        start_attempt(spec)
      else
        raise BadDep.new(@dep)
      end

      if sibling = next_sibling
        logger.debug "next sibling"
        sibling.resolve
        logger.debug "finished with sibling"
      else
        logger.debug "finished with no sibling"
      end
    rescue BadDep
      raise unless @dep.name == $!.latest_dep.name && @current_spec
      logger.warn "Invalidating the bad choice of spec: #{@current_spec.full_name}"
      root.invalidate(@current_spec)
      @current_spec = nil
      retry
    end

    def traverse
      if next_sibling
        next_sibling.resolve
      else
        @parent.traverse
      end
    end

    def previous_sibling
      if index = @parent.children.index(self)
        @parent.children[index - 1]
      end
    end

    def next_sibling
      if index = @parent.children.index(self)
        @parent.children[index + 1]
      else
        raise "Couldn't find #{inspect} in #{@parent.inspect}"
      end
    end

    def start_attempt(spec)
      if root.activated.include?(spec)
        logger.debug "already activated: #{spec.full_name}"
        return
      end

      logger.info "activating spec: #{spec.full_name}"
      @current_spec = spec
      attempt = Attempt.new(self)
      attempts[spec] = attempt
      attempt.resolve
    end

    def candidates
      if existing_spec = root.find_by_name(@dep.name)
        if existing_spec.satisfies_requirement?(@dep)
          [existing_spec]
        else
          []
        end
      else
        matches - root.invalid.to_a
      end
    end

    def matches
      source_index.search(@dep).reverse
    end

    def root
      @parent.root
    end

    def depth
      @parent.depth + 1
    end

    def header
      output "dep: #{@dep}"
      if satisfied?
        sub "satisfied!"
      else
        sub "not satisfied!"
      end
      sub "current: #{@current_spec ? @current_spec.full_name : '(none)'}"
      sub "candidates: (#{candidates.size}) #{candidates.map {|x| x.full_name}.join(', ')}"
    end

    def tree
      header
      attempts.each do |spec,attempt|
        sub "attempted spec: #{spec.full_name}"
        attempt.tree
      end
    end

    def sub(string)
      root.sub(string, depth)
    end

    def output(string)
      root.output(string, depth)
    end

    def satisfied?
      recursive_dependencies.all? do |dep|
        root.activated.any? do |spec|
          spec.satisfies_requirement?(dep)
        end
      end
    end

    def recursive_dependencies
      deps = [@dep]
      if current_attempt
        deps += current_attempt.recursive_dependencies
      end
      deps
    end

    def reset
      @invalid = []
      attempts.each do |spec,attempt|
        attempt.reset
      end
    end

    def activated
      gems = []
      if @current_spec
        gems << @current_spec
        if current_attempt
          gems += current_attempt.activated.dup
        end
      end
      gems
    end

    def source_index
      @parent.source_index
    end

    def runtime_dependencies
      @current_spec.runtime_dependencies
    end

    def current_attempt
      attempts[@current_spec]
    end

    def attempts
      @attempts ||= {}
    end

    def logger
      root.logger
    end
  end
end
