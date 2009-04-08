module GemResolver
  class State
    def self.resolve(attempt, dep)
      new(attempt, dep).resolve
    end

    def initialize(attempt, dep)
      @attempt, @dep = attempt, dep
      clear
    end

    def root
      @attempt.root
    end

    def clear
      @invalid = []
      attempts.each do |attempt|
        attempt.clear
      end
    end

    def activated
      @attempt.activated
    end

    def source_index
      @attempt.source_index
    end

    def resolve
      if spec = candidates.first
        attempt_for(spec).run
      else
        if @problem_spec
          raise BadSpec.new(@problem_spec)
        else
          raise UnableToSatifyDep, "Could not satisfy the dependency: #{@dep}"
        end
      end
      self
    rescue Reactivation
      @problem_spec = $!.spec
      @invalid << spec
      retry
    end

    def attempt_for(spec)
      if attempt = attempts.find {|x| x.spec == spec}
        attempt
      else
        attempts << Attempt.new(self, spec, nil)
        attempts.last
      end
    end

    def current_attempt
      attempts.last
    end

    def attempts
      @attempts ||= []
    end

    def candidates
      source_index.search(@dep).reverse - @invalid - root.invalid
    end
  end
end
