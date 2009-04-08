module GemResolver
  class Engine
    def self.search_for(dependencies, source_index)
      new(dependencies, source_index).search
    end

    def initialize(dependencies, source_index)
      @dependencies, @source_index = dependencies, source_index
    end

    def search
      matches = []
      @dependencies.each do |dep|
        if spec = @source_index.search(dep).last
          matches << spec
          matches += self.class.search_for(spec.dependencies, @source_index)
        else
          raise "Couldn't find match for #{dep}"
        end
      end
      matches
    end
  end
end
