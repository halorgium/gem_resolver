require File.dirname(__FILE__) + '/spec_helper'

module GemResolver
  describe "" do
    describe "with no gems" do
      it "has no gems" do
        index = build_index
        index.should contain_gems([])
      end
    end

    describe "with a single gem" do
      before(:each) do
        @index = build_index do
          add_spec "foo", "0.2.2"
        end
      end

      it "have the gem stored explicitly" do
        @index.should contain_gems([["foo", "0.2.2"]])
      end

      it "can search for that gem" do
        specs = @index.find_name("foo", "=0.2.2")
        specs.should match_gems([
          ["foo", "0.2.2"],
        ])
      end
    end

    describe "with a lots of gems" do
      before(:each) do
        @index = build_index do
          add_spec "foo", "0.2.1"
          add_spec "foo", "0.2.2"
          add_spec "foo", "0.3.0"
          add_spec "foo", "1.1.0"

          add_spec "bar", "0.2.2"
          add_spec "bar", "0.2.3"
          add_spec "bar", "0.2.4"
          add_spec "bar", "0.2.5"
          add_spec "bar", "0.3.5"
          add_spec "bar", "0.4.5"
        end
      end

      it "can search for 'foo', '>= 0.2.2'" do
        specs = @index.find_name("foo", ">= 0.2.2")
        specs.should match_gems([
          ["foo", "0.2.2"],
          ["foo", "0.3.0"],
          ["foo", "1.1.0"],
        ])
      end
    end
  end
end
