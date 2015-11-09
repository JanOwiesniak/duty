require "minitest/autorun"
require "open3"

class IntegrationSpec < MiniTest::Spec
  describe 'without a command' do
    it 'explains how to use the executable' do
      assert_stdout /(usage: duty <command> \[<args>\]\s+)/ do
        exec('bin/duty')
      end
    end
  end

  private

  def assert_stdout(expected, &command)
    stdout, stderr, status = yield command
    assert_match expected, stdout
  end

  def exec(command)
    Open3.capture3(command)
  end
end
