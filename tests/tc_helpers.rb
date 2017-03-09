require 'test/unit'

require_relative '../lib/brewer/helpers'

class TestHelpers < Test::Unit::TestCase

  def setup
    @brewer = Brewer.new
    # See comment on `test_log`
    @log = @brewer.base_path + '/logs/test_output'

    clear_log(@log)
  end

  def test_time
    assert_equal(String, time.class)
  end

  def test_log
    # This will give us the actual log i.e. '/logs/output'
    # For tests we use 'logs/test_output', which is why we have the
    # @log = @brewer.base_path + '/logs/test_output'
    # line
    assert_equal(String, log.class)
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
