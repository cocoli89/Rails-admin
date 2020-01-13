require 'spec_helper'

require_relative '../../../app/helpers/trestle/hook_helper'

describe Trestle::HookHelper do
  include Trestle::HookHelper

  include ActionView::Helpers::OutputSafetyHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Context

  describe "#hook" do
    it "calls and concatenates each hook" do
      Trestle.config.hook("test-hook") { "abc" }
      Trestle.config.hook("test-hook") { "123" }

      expect(hook("test-hook")).to eq("abc\n123")
    end

    it "yields if a block is provided an no hooks exist" do
      expect { |b| hook("no-hook", &b) }.to yield_control
    end

    it "does not yield if a hook exists" do
      Trestle.config.hook("test-hook") { "abc" }

      expect { |b| hook("test-hook", &b) }.not_to yield_control
    end
  end

  describe "#hook?" do
    it "returns true if there are global hooks defined for the given name" do
      Trestle.config.hook("test-hook") {}
      expect(hook?("test-hook")).to be true
    end

    it "returns false if there are no global hooks defined for the given name" do
      expect(hook?("no-hook")).to be false
    end
  end

  context "when an admin is available" do
    let(:admin) { double(hooks: Trestle::Hook::Set.new) }

    describe "#hook" do
      it "calls and concatenates global and admin hooks" do
        Trestle.config.hook("test-hook") { "global" }
        admin.hooks.append("test-hook") { "admin" }

        expect(hook("test-hook")).to eq("admin\nglobal")
      end
    end

    describe "#hook?" do
      it "returns true if there are admin hooks defined for the given name" do
        admin.hooks.append("admin-hook") { "admin" }
        expect(hook?("admin-hook")).to be true
      end

      it "returns false if there are no admin hooks defined for the given name" do
        expect(hook?("no-hook")).to be false
      end
    end
  end
end
