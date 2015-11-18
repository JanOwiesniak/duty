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
      assert_stdout /duty: `foo bar` is not a duty task\s{1}/ do
        exec("#{duty} foo bar")
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
        it 'explains what just happend' do
          assert_stdout /What just happend:\s{2}/ do
            exec("#{duty} test args")
          end
        end

        describe 'on failure' do
          it 'presents all executed tasks with adds additional errors' do
            assert_stdout /#{cross_mark} Done something great \| Executed `this_wont_work` in `.*`, No such file or directory - this_wont_work/ do
              exec("#{duty} test fail")
            end

            assert_stdout /#{check_mark} This was even greater\s{1}/ do
              exec("#{duty} test fail")
            end
          end
        end

        describe 'on success' do
          it 'presents all executed tasks' do
            assert_stdout /#{check_mark} Done something great\s{1}/ do
              exec("#{duty} test success")
            end

            assert_stdout /#{check_mark} This was even greater\s{1}/ do
              exec("#{duty} test success")
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
    assert_match expected, stdout, "Expected stdout to be #{expected} but got #{stdout}"
    assert_equal true, status.success?, "Expected status to be 0 but got #{status}"
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
