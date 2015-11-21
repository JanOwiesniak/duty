require "minitest/autorun"
require "open3"

class IntegrationSpec < MiniTest::Spec
  describe 'without a command' do
    it 'explains how to use the executable' do
      assert_stdout /Usage: duty <command> \[<args>\]\s{1}/ do
        exec(duty)
      end
    end

    it 'lists all available commands' do
      assert_stdout /Commands:/ do
        exec(duty)
      end

      assert_stdout /test\s*This is a test command/ do
        exec(duty)
      end
    end
  end

  describe 'with unknown command' do
    it 'explains that the given command is invalid' do
      assert_stdout /duty: `foo bar` is not a duty command\s{1}/ do
        exec("#{duty} foo bar")
      end
    end
  end

  describe 'with --cmplt for shell completion' do
    it 'returns all commands without input' do
      assert_stdout /start-feature\stest/ do
        exec("#{duty} --cmplt")
      end
    end

    it 'returns matching commands with input' do
      assert_stdout /test/ do
        exec("#{duty} --cmplt t")
      end
    end
  end

  describe 'with known command' do
    describe 'test' do
      describe 'invalid usage' do
        it 'describes the command' do
          assert_stdout /This is a test command\s{1}/ do
            exec("#{duty} test")
          end
        end

        it 'explains how to use the command' do
          assert_stdout /Usage: duty test \[<args>\]\s{1}/ do
            exec("#{duty} test")
          end
        end
      end

      describe 'valid usage' do
        describe 'on success' do
          it 'displays all executed commands' do
            assert_stdout /#{check_mark} Done something great/ do
              exec("#{duty} test success")
            end

            assert_stdout /#{check_mark} This was even greater/ do
              exec("#{duty} test success")
            end
          end
        end

        describe 'on failure' do
          it 'displays executed commands' do
            assert_stdout /#{cross_mark} Done something great/ do
              exec("#{duty} test fail")
            end
          end

          it 'does not display not executed commands' do
            refute_stdout /This was even greater/ do
              exec("#{duty} test fail")
            end
          end
        end
      end
    end
  end

  private

  def duty
    File.expand_path("../../bin/duty", __FILE__)
  end

  def duty_file
    '.duty.yml'
  end

  def check_mark
    "\u2713".encode('utf-8')
  end

  def cross_mark
    "\u2715".encode('utf-8')
  end

  def assert_stdout(expected, &command)
    stdout, stderr, status = yield command
    assert_match expected, stdout, "Expected stdout to be #{expected} but got #{stdout}"
    assert_equal true, status.success?, "Expected status to be 0 but got #{status}"
  end

  def refute_stdout(expected, &command)
    stdout, stderr, status = yield command
    refute_match expected, stdout, "Expected stdout to be #{expected} but got #{stdout}"
  end

  def exec(*commands)
    duty_config = "commands: #{__dir__}/support"
    Dir.mktmpdir do |dir|
      commands.each do |command|
        @last_command = capture(command, :chdir => dir, :duty_config => duty_config)
      end
      @last_command
    end
  end

  def capture(command, options = {})
    if duty_config = options.delete(:duty_config)
      Open3.capture3("echo '#{duty_config}' > #{duty_file}", options)
    end

    stdout, stderr, status = Open3.capture3(command, options)
  end
end
