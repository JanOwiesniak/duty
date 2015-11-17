require "minitest/autorun"
require "duty/meta"

class MetaHumanizerSpec < MiniTest::Spec
  describe "humanizer" do
    subject { Duty::Meta::Humanizer.new }

    it "humanizes commands" do
      expected = "some-command"
      assert_equal expected, subject.command("Duty::Commands::SomeCommand")
    end
  end
end
