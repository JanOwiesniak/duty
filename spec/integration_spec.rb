require "minitest/autorun"
require "open3"

class IntegrationSpec < MiniTest::Spec
  describe 'without a task' do
    it 'explains how to use the executable' do
      assert_stdout /Usage: duty <task> \[<args>\]\s{1}/ do
        exec(duty)
      end
    end

    it 'lists all available tasks' do
      assert_stdout /Tasks:/ do
        exec(duty)
      end

      assert_stdout /test\s*This is a test task/ do
        exec(duty)
      end
    end
  end

  describe 'with unknown task' do
    it 'explains that the given task is invalid' do
      assert_stdout /duty: `foo bar` is not a duty task/ do
        exec("#{duty} foo bar")
      end
    end
  end

  describe 'with --cmplt for shell completion' do
    it 'returns all tasks without input' do
      assert_stdout /test/ do
        exec("#{duty} --cmplt")
      end
    end

    it 'returns matching tasks with input' do
      assert_stdout /test/ do
        exec("#{duty} --cmplt t")
      end
    end
  end

  describe 'with known task' do
    describe 'test' do
      describe 'invalid usage' do
        it 'describes the task' do
          assert_stdout /This is a test task\s{1}/ do
            exec("#{duty} test")
          end
        end

        it 'explains how to use the task' do
          assert_stdout /Usage: duty test \[<args>\]\s{1}/ do
            exec("#{duty} test")
          end
        end
      end

      describe 'valid usage' do
        describe 'with shell tasks' do
          it 'stops execution as soon as one task fails' do
            assert_stdout /#{check_mark} First shell task/ do
              exec("#{duty} test shell")
            end

            assert_stderr /#{cross_mark} Second shell task/ do
              exec("#{duty} test shell")
            end

            refute_stdout /Third shell task/ do
              exec("#{duty} test shell")
            end

            refute_stderr /Third shell task/ do
              exec("#{duty} test shell")
            end
          end
        end

        describe 'with ruby tasks' do
          it 'stops execution as soon as one task fails' do
            assert_stdout /#{check_mark} First ruby task/ do
              exec("#{duty} test ruby")
            end

            assert_stderr /#{cross_mark} Second ruby task/ do
              exec("#{duty} test ruby")
            end

            refute_stdout /Third shell ruby/ do
              exec("#{duty} test ruby")
            end

            refute_stderr /Third shell ruby/ do
              exec("#{duty} test ruby")
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

  def assert_stdout(expected, &task)
    stdout, stderr, status = yield task
    unless status.success?
      assert_equal 0, status.exitstatus, stderr
    end
    assert_match expected, stdout, "Expected stdout to be #{expected} but got #{stdout}"
  end

  def refute_stdout(expected, &task)
    stdout, _, _ = yield task
    refute_match expected, stdout, "Expected stdout to be #{expected} but got #{stdout}"
  end

  def assert_stderr(expected, &task)
    stdout, stderr, status = yield task
    unless status.success?
      assert_equal 0, status.exitstatus, stderr
    end
    assert_match expected, stderr, "Expected stdout to be #{expected} but got #{stderr}"
  end

  def refute_stderr(expected, &task)
    _, stderr, _ = yield task
    refute_match expected, stderr, "Expected stdout to be #{expected} but got #{stderr}"
  end

  def exec(*tasks)
    duty_config = "tasks: #{__dir__}/support"
    Dir.mktmpdir do |dir|
      tasks.each do |task|
        @last_task = capture(task, :chdir => dir, :duty_config => duty_config)
      end
      @last_task
    end
  end

  def capture(task, options = {})
    if duty_config = options.delete(:duty_config)
      Open3.capture3("echo '#{duty_config}' > #{duty_file}", options)
    end

    stdout, stderr, status = Open3.capture3(task, options)
  end
end
