require File.dirname(__FILE__) + '/spec_helper'

module GemResolver
  describe "Resolving specs" do
    it "supports a single dependency" do
      index = build_index do
        add_spec "bar", "2.0.0"
      end

      deps = [
        ["bar", ">= 1.2.3"],
      ]

      specs = GemResolver.dependencies_in(index, deps)
      specs.should match_gems(
        "bar" => ["2.0.0"]
      )
    end

    it "supports nested dependencies" do
      index = build_index do
        add_spec "bar", "2.0.0" do
          runtime "foo", ">= 1"
        end
        add_spec "foo", "1.1"
      end

      deps = [
        ["bar", ">= 1.2.3"],
      ]

      specs = GemResolver.dependencies_in(index, deps)
      specs.should match_gems(
        "bar" => ["2.0.0"],
        "foo" => ["1.1"]
      )
    end

    it "supports locked dependencies" do
      index = build_index do
        add_spec "bar", "1.0" do
          runtime "foo", "= 1.0"
        end
        add_spec "bar", "1.1" do
          runtime "foo", "= 1.1"
        end
        add_spec "foo", "1.0"
        add_spec "foo", "1.1"
      end

      deps = [
        ["bar", ">= 1.0"],
        ["foo", "= 1.0"],
      ]

      specs = GemResolver.dependencies_in(index, deps)
      specs.should match_gems(
        "bar" => ["1.0"],
        "foo" => ["1.0"]
      )
    end

    it "supports merb-core" do
      index = Gem.source_index

      deps = [
        ["merb-core", "= 1.0.7.1"],
      ]

      specs = GemResolver.dependencies_in(index, deps)
      specs.should match_gems(
        "merb-core"=>["1.0.7.1"],
        "rake"=>["0.8.4"],
        "thor"=>["0.9.9"],
        "rspec"=>["1.2.2"],
        "mime-types"=>["1.16"],
        "abstract"=>["1.0.0"],
        "rack"=>["0.9.1"],
        "erubis"=>["2.6.2"],
        "extlib"=>["0.9.11"],
        "json_pure"=>["1.1.3"]
      )
    end

    it "supports impossible situations" do
      index = build_index do
        add_spec "a", "1.0"
      end

      deps = [
        ["a", "= 1.1"],
      ]

      lambda { GemResolver.dependencies_in(index, deps) }.
        should raise_error(UnableToSatifyDep, "Could not satisfy the dependency: a (= 1.1, runtime)")
    end
  end
end
