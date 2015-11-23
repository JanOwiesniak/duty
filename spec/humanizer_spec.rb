require "minitest/autorun"
require "duty/meta"

class MetaHumanizerSpec < MiniTest::Spec
  describe "humanizer" do
    subject { Duty::Meta::Humanizer.new }

    it "humanizes tasks" do
      expected = "some-task"
      assert_equal expected, subject.task("Duty::Tasks::SomeTask")
    end
  end
end
