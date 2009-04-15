module GemResolver
  class Engine
    def self.resolve(dependencies, source_index, logger)
      new(dependencies, source_index, logger).resolve
    end

    def initialize(dependencies, source_index, logger)
      @source_index, @logger = source_index, logger

      deps = []
      dependencies.each do |name,requirements|
        deps << Gem::Dependency.new(name, requirements)
      end
      add(nil, nil, deps)
    end
    attr_reader :source_index, :logger

    def resolve
      logger.debug "starting up"
      until unmet_deps.empty?
        dep = unmet_deps.first
        logger.debug "trying for #{dep}"
        if gem = gem_for(dep)
          logger.debug "found gem: #{gem.full_name}"
          add(dep, gem, gem.runtime_dependencies)
        end
      end
      logger.debug "no deps left"
      activated_gems
    end

    def add(dep, gem, deps)
      new_deps = []
      deps.each do |d|
        new_deps << d unless all_deps.include?(d)
      end
      logger.debug "adding new deps: #{new_deps.inspect}"
      stack << [dep, gem, new_deps]
    end

    def rollback_to(dep)
      if stack.size == 1
        raise BadDep.new(dep)
      end

      until stack.last.last.include?(dep)
        logger.debug "about to pop #{stack.last.inspect}"
        dep, gem, deps = stack.pop
      end

      logger.debug "about to invalidate #{gem.full_name}"
      invalid_gems << gem
    end

    def gem_for(dep)
      matches = source_index.search(dep).reverse
      gems = (matches - invalid_gems).select do |gem|
        compatible_with_deps?(gem)
      end

      return gems.first if gems.first

      rollback_to(dep)
      false
    end

    def compatible_with_deps?(gem)
      deps_matching(gem.name).all? do |dep|
        gem.satisfies_requirement?(dep)
      end
    end

    def unmet_deps
      all_deps.reject do |dep|
        activated_gems.any? do |gem|
          gem.satisfies_requirement?(dep)
        end
      end
    end

    def all_deps
      all_deps = []
      stack.each do |dep,gem,deps|
        all_deps += deps
      end
      all_deps
    end

    def activated_gems
      activated_gems = []
      stack.each do |dep,gem,deps|
        activated_gems << gem if gem
      end
      activated_gems
    end

    def deps_matching(name)
      all_deps.select do |dep|
        dep.name == name
      end
    end

    def dump
      puts "*" * 80
      puts "stack is"
      stack.each do |dep,gem,deps|
        puts "#{dep || "<top>"} --> #{gem && gem.full_name || "<top>"}"
        deps.each do |d|
          puts "-> #{d}"
        end
        puts "-" * 80
      end
      puts "*" * 80
    end

    def invalid_gems
      @invalid_gems ||= []
    end

    def stack
      @stack ||= []
    end
  end
end
