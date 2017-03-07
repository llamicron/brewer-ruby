require 'test/unit'
require_relative '../src/brewer'
require_relative '../src/adaptibrew'

class TestBrewer < Test::Unit::TestCase

  def setup
    @brewer = Brewer.new
    @adaptibrew = Adaptibrew.new.refresh
    # This is used for log testing, not logging tests see `test_log_methods`
    @log = @brewer.base_path + '/logs/output'
  end

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

  def test_clear_output
    @brewer.script('python_tester')
    assert_equal("it worked", @brewer.out.first)
    @brewer.clear
    assert_equal(nil, @brewer.out.first)
  end

  # Kind of a beefy test. This covers all of the log functions.
  def test_log_methods
    # Clear output
    @brewer.clear
    assert_true(!@brewer.out.any?)

    # Clear log
    @brewer.clear_log
    assert_true(File.zero?(@log))

    # Get some output
    @brewer.script('python_tester')
    # (Output should be "it worked")
    assert_true(@brewer.out.any?)

    # Write output
    @brewer.write_log
    assert_true(!File.zero?(@log))

    # Read output log
    @brewer.read_log
    assert_true(@brewer.out.first.include?("it worked"))
  end

end
