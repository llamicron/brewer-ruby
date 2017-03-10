require 'test/unit'

require_relative '../lib/helpers'

class TestHelpers < Test::Unit::TestCase

  def setup
    @brewer = Brewer.new
    # See comment on `test_log`
    @log = @brewer.base_path + '/logs/test_output'
    clear_log(@log)
  end

  # Test that Helpers#time will rturn a string
  # Not sure how to test the format, since that would require knowing the actual
  # time. Might get messy.
  def test_time
    assert_equal(String, time.class)
  end

  def test_log
    # This will give us the actual log i.e. '/logs/output', not the test log
    assert_equal(Dir.pwd + "/logs/output", log)
  end

  def test_log_methods
    # Clear adaptibrew ouput from brewer
    @brewer.clear

    clear_log(@log)
    assert_true(File.zero?(@log))

    # Get some output
    @brewer.script('python_tester')
    assert_true(@brewer.out.any?)

    # Write output
    write_log(@log, @brewer.out)
    assert_true(!File.zero?(@log))
  end

end
