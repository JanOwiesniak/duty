require "minitest/autorun"
require "open3"

class IntegrationSpec < MiniTest::Spec
  describe 'without a command' do
    it 'explains how to use the executable' do
      assert_stdout /Usage: duty <command> \[<args>\]\s{1}/ do
        exec('duty')
      end
    end

    it 'lists all available commands' do
      assert_stdout /Commands:\n\n\s{2}new-feature\s{9}Creates a new feature branch\n/ do
        exec('duty')
      end
    end
  end

  describe 'with unknown command' do
    it 'explains that the given command is invalid' do
      assert_stdout /duty: `foo bar` is not a duty command\s{1}/ do
        exec('duty foo bar')
      end
    end
  end

  describe 'with known command' do
    describe 'new-feature' do
      describe 'without name' do
        it 'describes the command' do
          assert_stdout /Creates a new feature branch\s{1}/ do
            exec('duty new-feature')
          end
        end

        it 'explains how to use the command' do
          assert_stdout /Usage: duty new-feature <name>\s{1}/ do
            exec('duty new-feature')
          end
        end
      end

      describe 'with name' do
        it 'explains what just happend' do
          assert_stdout /What just happend:\s{2}/ do
            exec('git init', 'git commit -m "" --allow-empty-message --allow-empty', 'git remote add origin .', 'duty new-feature my-awesome-feature')
          end
        end

        it 'checks out the `master` branch' do
          assert_stdout /#{check_mark} Checkout `master` branch\s{1}/ do
            exec('git init', 'git commit -m "" --allow-empty-message --allow-empty', 'git remote add origin .', 'duty new-feature my-awesome-feature')
          end
        end

        it 'checks out the new feature branch' do
          assert_stdout /#{check_mark} Checkout `feature\/my-awesome-feature` branch\s{1}/ do
            exec('git init', 'git commit -m "" --allow-empty-message --allow-empty', 'git remote add origin .', 'duty new-feature my-awesome-feature')
          end
        end

        it 'pushs new feature branch to origin' do
          assert_stdout /#{check_mark} Push `feature\/my-awesome-feature` branch to `origin`\s{1}/ do
            exec('git init', 'git commit -m "" --allow-empty-message --allow-empty', 'git remote add origin .', 'duty new-feature my-awesome-feature')
          end
        end
      end
    end
  end

  private

  def check_mark
    "\u2713".encode('utf-8')
  end

  def assert_stdout(expected, &command)
    stdout, stderr, status = yield command
    assert_match expected, stdout, "Expected stdout to be #{expected} but got #{stdout}"
    assert_equal true, status.success?, "Expected status to be 0 but got #{status}"
  end

  def exec(*commands)
    Dir.mktmpdir do |dir|
      commands.each do |command|
        @last_command = capture(command, :chdir => dir)
      end
      @last_command
    end
  end

  def capture(command, options = {})
    stdout, stderr, status = Open3.capture3(command, options)
  end
end
