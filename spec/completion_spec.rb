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
    FakeRegistry.new([
      fake_task("TaskA", "Some description"),
      fake_task("TaskB", "task-a is my family")
    ])
  end

  def fake_task(*args)
    FakeTask.new(*args)
  end

  FakeCli = Struct.new(:registry)
  FakeRegistry = Struct.new(:all)
  class FakeTask < Struct.new(:name, :description)
    def to_s
      "Duty::Tasks::#{name}"
    end
  end
end
