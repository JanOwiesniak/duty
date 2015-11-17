require "minitest/autorun"
require "duty/meta"

class MetaCompletionSpec < MiniTest::Spec
  describe "help" do
    subject { Duty::Meta::Completion }

    it "returns all commands for no input" do
      expected = "command-a\ncommand-b"
      assert_equal expected, subject.new(fake_cli, []).to_s
      assert_equal expected, subject.new(fake_cli, ['']).to_s
    end

    it "returns matching commands by humanized name" do
      expected = "command-b"
      assert_equal expected, subject.new(fake_cli, %w[command-b]).to_s
    end
  end

  private

  def fake_cli
    FakeCli.new(fake_registry)
  end

  def fake_registry
    FakeRegistry.new([
      fake_command("CommandA", "Some description"),
      fake_command("CommandB", "command-a is my family")
    ])
  end

  def fake_command(*args)
    FakeCommand.new(*args)
  end

  FakeCli = Struct.new(:registry)
  FakeRegistry = Struct.new(:all)
  class FakeCommand < Struct.new(:name, :description)
    def to_s
      "Duty::Commands::#{name}"
    end
  end
end
