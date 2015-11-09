require "minitest/autorun"
require "open3"

class IntegrationSpec < MiniTest::Spec
  describe 'without a command' do
    it 'explains how to use the executable' do
      assert_stdout /usage: duty <command> \[<args>\]\s{1}/ do
        exec('bin/duty')
      end
    end

    it 'lists all available commands' do
      assert_stdout /Commands:\s{2}new-feature\tCreates a new feature branch\s{1}/ do
        exec('bin/duty')
      end
    end
  end

  describe 'with unknown command' do
    it 'explains that the given command is invalid' do
      assert_stdout /duty: `foo bar` is not a duty command\s{1}/ do
        exec('bin/duty foo bar')
      end
    end
  end

  describe 'with known command' do
    describe 'new-feature' do
      describe 'without name' do
        it 'describes the command' do
          assert_stdout /Creates a new feature branch\s{1}/ do
            exec('bin/duty new-feature')
          end
        end

        it 'explains how to use the command' do
          assert_stdout /usage: duty new-feature <name>\s{1}/ do
            exec('bin/duty new-feature')
          end
        end
      end

      describe 'with name' do
        it 'explains what just happend' do
          assert_stdout /What just happend:\s{2}/ do
            exec('bin/duty new-feature my-awesome-feature')
          end
        end

        it 'checks out the `master` branch' do
          assert_stdout /Checked out `master` branch\s{1}/ do
            exec('bin/duty new-feature my-awesome-feature')
          end
        end

        it 'creates a new feature branch' do
          assert_stdout /Created new feature branch `feature\/my-awesome-feature`\s{1}/ do
            exec('bin/duty new-feature my-awesome-feature')
          end
        end

        it 'checks out the new feature branch' do
          assert_stdout /Checked out new feature branch `feature\/my-awesome-feature`\s{1}/ do
            exec('bin/duty new-feature my-awesome-feature')
          end
        end

        it 'pushs new feature branch to origin' do
          assert_stdout /Pushed new feature branch `feature\/my-awesome-feature` to `origin`\s{1}/ do
            exec('bin/duty new-feature my-awesome-feature')
          end
        end
      end
    end
  end

  private

  def assert_stdout(expected, &command)
    stdout, stderr, status = yield command
    assert_match expected, stdout
    assert_equal true, status.success?
  end

  def exec(command)
    Open3.capture3(command)
  end
end
