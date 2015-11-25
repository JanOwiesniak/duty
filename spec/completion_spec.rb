require "minitest/autorun"
require "duty/meta"

class MetaCompletionSpec < MiniTest::Spec
  describe "help" do
    subject { Duty::Meta::Completion }

    it "returns all tasks for no input" do
      expected = "task-a\ntask-b"
      assert_equal expected, subject.new(fake_cli, []).to_s
      assert_equal expected, subject.new(fake_cli, ['']).to_s
    end

    it "returns matching tasks by humanized name" do
      expected = "task-b"
      assert_equal expected, subject.new(fake_cli, %w[task-b]).to_s
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
      def tasks
        [
          TaskA,
          TaskB
        ]
      end

      class TaskA
      end

      class TaskB
      end
    end
  end
end
