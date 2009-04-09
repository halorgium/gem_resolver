module GemResolver
  class Attempt
    def self.resolve(parent)
      new(parent).resolve
    end

    def initialize(parent)
      @parent = parent
      reset
    end
    attr_reader :parent

    def resolve
      logger.debug "starting to resolve deps: #{dependencies_string}"
      if child = children.first
        try(child)
      else
        @parent.traverse
      end
      logger.debug "finishing to resolve deps: #{dependencies_string}"
    end

    def try(child)
      child.resolve
    rescue BadDep
      raise unless child.dep == $!.latest_dep
      logger.warn "Handling the dep which can't be resolved: #{child.dep}"
      raise BadDep.new(@parent.dep, *$!.deps)
    end

    def traverse
      @parent.traverse
    end

    def root
      @parent.root
    end

    def depth
      @parent.depth + 1
    end

    def header
      output "deps: (#{dependencies.size}) #{dependencies_string}"
      sub "activated: (#{activated.size}) #{activated.map {|x| x.full_name}.join(', ')}"
    end

    def tree
      header
      children.each do |child|
        child.tree
      end
    end

    def sub(string)
      root.sub(string, depth)
    end

    def output(string)
      root.output(string, depth)
    end

    def reset
      children.each do |child|
        child.reset
      end
    end

    def recursive_dependencies
      deps = []
      children.each do |child|
        deps += child.recursive_dependencies
      end
      deps
    end

    def activated
      gems = []
      children.each do |child|
        gems += child.activated
      end
      gems
    end

    def source_index
      @parent.source_index
    end

    def first?
      @parent == root
    end

    def dependencies
      @parent.runtime_dependencies
    end

    def dependencies_string
      dependencies.map {|x| x.to_s}.join(', ')
    end

    def children
      @children ||= dependencies.map do |dep|
        State.new(self, dep)
      end
    end

    def logger
      root.logger
    end
  end
end
