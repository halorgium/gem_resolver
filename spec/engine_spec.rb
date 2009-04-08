require File.dirname(__FILE__) + '/spec_helper'

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
      "bar" => ["2.0.0"],
      "foo" => ["1.1"]
    )
  end

  it "supports locked dependencies" do
    pending

    index = build_index do
      add_spec "bar", "1.0" do
        runtime "foo", "= 1.0"
      end
      add_spec "bar", "1.1" do
        runtime "foo", "= 1.1"
      end
      add_spec "foo", "1.1"
    end

    spec = build_spec "meta", "0" do
      runtime "bar", ">= 1.2.3"
      runtime "foo", "= 1.0"
    end

    specs = spec.resolved_dependencies_in(index)
    specs.should match_gems(
      "bar" => "2.0.0",
      "foo" => "1.1"
    )
  end
end
