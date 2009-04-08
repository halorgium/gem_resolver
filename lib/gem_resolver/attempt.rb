module GemResolver
  class Attempt
    def self.run(state, spec, source_index)
      new(state, spec, source_index).run
    end

    def initialize(state, spec, source_index)
      @state, @spec, @source_index = state, spec, source_index
      @invalid = []
      clear
    end
    attr_reader :spec, :invalid

    def root
      @state ? @state.root : self
    end

    def clear
      @activated = Set.new
      children.each do |child|
        child.clear
      end
    end

    def activated
      gems = @activated.dup
      children.each do |child|
        if attempt = child.current_attempt
          gems += attempt.activated
        end
      end
      gems
    end

    def source_index
      @state ? @state.source_index : @source_index
    end

    def run
      if existing_spec = root.activated.find {|x| x.name == @spec.name}
        if existing_spec == @spec
          return
        end
        raise Reactivation.new(@spec, existing_spec)
      end
      @activated << @spec unless self == root
      children.each do |child|
        child.resolve
      end
      activated.to_a
    rescue UnableToSatifyDep
      raise if self == root
      raise BadSpec.new(@spec)
    rescue BadSpec
      raise unless self == root
      root.clear
      @invalid << $!.spec
      retry
    end

    def children
      @children ||= @spec.runtime_dependencies.map do |dep|
        State.new(self, dep)
      end
    end
  end
end
