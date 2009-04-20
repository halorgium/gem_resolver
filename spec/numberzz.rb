require File.dirname(__FILE__) + '/../lib/depth_first_search'

class Numberzz
  include DepthFirstSearch

  def self.start(size)
    new(size).start
  end

  def initialize(size)
    @goal = []
    @size = size
    @size.times do
      @goal << rand(10)
    end
    puts "searching for #{@goal.inspect}"
  end
  attr_reader :goal, :size

  def start
    state = State.initial(self, [])
  end

  class State
    include DepthFirstSearch::Node

    def initialize(depth, numberzz, values)
      super(depth)
      @numberzz, @values = numberzz, values
    end

    def goal_met?
      @numberzz.goal == @values
    end

    def each_possibility
      return if @data.size >= @numberzz.size
      (0..9).map do |i|
        yield child(@data + [i])
      end
    end
  end
end

puts Numberzz.start(Integer(ARGV.first)).inspect
