require 'set'

module DepthFirstSearch
  def search(initial, max_depth = (1.0 / 0.0))
    if initial.goal_met?
      return initial
    end

    open << initial

    while open.any?
      @current = open.pop
      if ENV["VISUALIZE"]
        puts "%3d, %-80s | %-30s, %3d : %s" % [open.size, "*" * open.size, @current.path.join(", "), @current.depth, "!" * @current.depth]
      end
      closed << @current

      @current.each_possibility do |@attempt|
        unless closed.include?(@attempt)
          if @attempt.goal_met?
            return @attempt
          elsif @attempt.depth < max_depth
            open << @attempt
          end
        else
          open << @attempt
        end
      end
    end
    raise "no solution"
  end
  attr_reader :current, :attempt

  def open
    raise "implement #open in #{self.class}"
  end

  def closed
    raise "implement #closed in #{self.class}"
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
