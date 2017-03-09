require 'test/unit'
require_relative '../lib/brewer/brewer'
require_relative '../lib/brewer/adaptibrew'

class TestBrewer < Test::Unit::TestCase

  def setup
    @brewer = Brewer.new
    @adaptibrew = Adaptibrew.new.refresh
    # This is used for log testing, not logging tests see `test_log_methods`
    @log = @brewer.base_path + '/logs/test_output'
  end

  # Make sure that the path is correct. I hate working with paths.
  # TODO: Test this on windows
  def test_base_path
    assert_equal(Dir.pwd, @brewer.base_path)
  end

  # Don't really know how to test this one...
  # Just running the code for coverage and to pick up any stray errors
  def test_wait
    @brewer.wait(0.1)
    assert_true(true)
  end

  def test_script_and_output
    @brewer.script('python_tester')
    assert_equal("it worked", @brewer.out.first)
  end

  # Tests if the adaptibrew output (@brewer.out) can be cleared.
  # This invloves writing to the log file
  def test_clear_output
    @brewer.script('python_tester')
    assert_equal("it worked", @brewer.out.first)
    @brewer.clear
    assert_equal(nil, @brewer.out.first)
  end

end
