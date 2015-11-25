require "minitest/autorun"
require "duty/meta"

class MetaHelpSpec < MiniTest::Spec
  describe "help" do
    subject { Duty::Meta::Help.new(fake_cli) }

    it "returns information about all tasks" do
      expected = /Usage:.*\s+Tasks:\s+\[my namespace\]\s+.*my description\s+/
      assert_match expected, subject.to_s
    end
  end

  private

  def fake_cli
    FakeCli.new(fake_registry)
  end

  def fake_registry
    FakeRegistry.new
  end

  class FakeCli
    def initialize(registry)
      @registry = registry
    end

    def registry
      @registry
    end
  end

  class FakeRegistry
    def plugins
      [
        FakePlugin.new
      ]
    end

    class FakePlugin
      def namespace
        "my namespace"
      end

      def tasks
        [
          FakeTask
        ]
      end

      class FakeTask
        def self.description
          'my description'
        end
      end
    end
  end
end
