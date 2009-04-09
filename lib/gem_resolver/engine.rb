module GemResolver
  class Engine
    def self.resolve(dependencies, source_index, logger)
      new(dependencies, source_index, logger).run
    end

    def initialize(dependencies, source_index, logger)
      @dependencies = dependencies.map {|x| Gem::Dependency.new(*x)}
      @source_index, @logger = source_index, logger
    end
    attr_reader :source_index, :logger

    def run
      attempt.resolve
      activated
    end

    def attempt
      @attempt ||= Attempt.new(self)
    end

    def activated
      attempt.activated
    end

    def recursive_dependencies
      attempt.recursive_dependencies
    end

    def runtime_dependencies
      @dependencies.select {|x| x.type == :runtime}
    end

    def find_by_name(name)
      activated.find {|x| x.name == name}
    end

    def root
      self
    end

    def depth
      0
    end

    def tree
      logger.debug "=" * 80
      logger.debug "| Tree"
      logger.debug "=" * 80
      logger.debug "activated: (#{activated.size}) #{activated.map {|x| x.full_name}.join(', ')}"
      logger.debug "deps: (#{recursive_dependencies.size}) #{recursive_dependencies.map {|x| x.to_s}.join(', ')}"
      logger.debug "invalid: (#{invalid.size}) #{invalid.map {|x| x.full_name}.join(', ')}"
      logger.debug "-" * 80
      attempt.tree
      logger.debug "=" * 80
    end

    def sub(string, depth)
      spacer = '|   ' * depth + '\--> '
      logger.debug spacer + string
    end

    def output(string, depth)
      spacer = '|   ' * (depth - 1) + '\---'
      logger.debug spacer + string
    end

    def dep
      '<top>'
    end

    def traverse
      logger.debug "the results are: "
      logger.debug "activated: (#{activated.size}) #{activated.map {|x| x.full_name}.join(', ')}"
    end

    def invalidate(spec)
      logger.debug "invalidating #{spec.full_name}"
      invalid << spec
    end

    def invalid
      @invalid ||= Set.new
    end

    def reset
      @invalid = nil
    end
  end
end
