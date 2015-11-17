require "minitest/autorun"
require "duty/meta"

class MetaHelpSpec < MiniTest::Spec
  describe "help" do
    subject { Duty::Meta::Help.new(fake_cli) }

    it "returns information about all commands" do
      expected = /Usage:.*\s+Commands:\s+command-a\s+Some description/
      assert_match expected, subject.to_s
    end
  end

  private

  def fake_cli
    FakeCli.new(fake_registry)
  end

  def fake_registry
    FakeRegistry.new([
      fake_command("CommandA", "Some description"),
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
