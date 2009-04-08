require File.dirname(__FILE__) + '/spec_helper'

describe "Resolving specs" do
  it "works" do
    index = build_index do
      add_spec "bar", "2.0.0"
    end

    spec = build_spec "foo", "1.2.3" do
      runtime "bar", ">= 1.2.3"
    end

    specs = spec.resolved_dependencies_in(index)
    specs.should match_gems([
      ["bar", "2.0.0"],
    ])
  end
end
