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

  describe 'with unknown command' do
    it 'explains that the given command is invalid' do
      assert_stdout /duty: `foo bar` is not a duty command\s{2}/ do
        exec('bin/duty foo bar')
      end
    end
  end

  describe 'with known command' do
    describe 'new-feature' do
      it 'describes the command' do
        assert_stdout /Creates a new feature branch\s{2}/ do
          exec('bin/duty new-feature')
        end
      end

      it 'explains how to use the command' do
        assert_stdout /usage: duty new-feature <name>\s{2}/ do
          exec('bin/duty new-feature')
        end
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