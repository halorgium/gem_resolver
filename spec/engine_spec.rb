require File.dirname(__FILE__) + '/spec_helper'

module GemResolver
  describe "Resolving specs" do
    it "supports a single dependency" do
      index = build_index do
        add_spec "bar", "2.0.0"
      end

      spec = build_spec "meta", "0" do
        runtime "bar", ">= 1.2.3"
      end

      specs = spec.resolved_dependencies_in(index)
      specs.should match_gems(
        "meta" => ["0"],
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

      spec = build_spec "meta", "0" do
        runtime "bar", ">= 1.2.3"
      end

      specs = spec.resolved_dependencies_in(index)
      specs.should match_gems(
        "meta" => ["0"],
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

      spec = build_spec "meta", "0" do
        runtime "bar", ">= 1.0"
        runtime "foo", "= 1.0"
      end

      specs = spec.resolved_dependencies_in(index)
      specs.should match_gems(
        "meta" => ["0"],
        "bar" => ["1.0"],
        "foo" => ["1.0"]
      )
    end

    it "supports merb-core" do
      index = Gem.source_index

      spec = build_spec "meta", "0" do
        runtime "merb-core", "= 1.0.7.1"
      end

      specs = spec.resolved_dependencies_in(index)
      specs.should match_gems(
        "meta"=>["0"],
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

      spec = build_spec "meta", "0" do
        runtime "a", "= 1.1"
      end

      lambda { spec.resolved_dependencies_in(index) }.
        should raise_error(UnableToSatifyDep, "Could not satisfy the dependency: a (= 1.1, runtime)")
    end
  end
end
