require 'set'

module DepthFirstSearch
  def search(initial, max_depth = (1.0 / 0.0))
    if initial.goal_met?
      return initial
    end

    open = []
    closed = Set.new

    open << initial

    while open.any?
      n = open.shift
      closed << n

      n.each_possibility do |attempt|
        unless closed.include?(attempt)
          if attempt.goal_met?
            return attempt
          elsif attempt.depth < max_depth
            open << attempt
          end
        end
      end
    end
    raise "no solution"
  end

  module Node
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def initial(*data)
        new(0, *data)
      end
    end

    def initialize(depth)
      @depth = depth
    end
    attr_reader :depth

    def child(*data)
      self.class.new(@depth + 1, *data)
    end

    def each_possibility
      raise "implement #each_possibility on #{self.class}"
    end

    def goal_met?
      raise "implement #goal_met? on #{self.class}"
    end
  end
end
