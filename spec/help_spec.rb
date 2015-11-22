require "minitest/autorun"
require "duty/meta"

class MetaHelpSpec < MiniTest::Spec
  describe "help" do
    subject { Duty::Meta::Help.new(fake_cli) }

    it "returns information about all tasks" do
      expected = /Usage:.*\s+Tasks:\s+task-a\s+Some description/
      assert_match expected, subject.to_s
    end
  end

  private

  def fake_cli
    FakeCli.new(fake_registry)
  end

  def fake_registry
    FakeRegistry.new([
      fake_task("TaskA", "Some description"),
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
