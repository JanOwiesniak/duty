require "minitest/autorun"
require "open3"

class IntegrationSpec < MiniTest::Spec
  describe 'without a command' do
    it 'explains how to use the executable' do
      assert_stdout /(usage: duty <command> \[<args>\]\s{2})/ do
        exec('bin/duty')
      end
    end

    it 'lists all available commands' do
      assert_stdout /.*(Commands:\s{2}new-feature\tCreates a new feature branch)/ do
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
