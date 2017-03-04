require 'test/unit'
require_relative '../src/brewer'
require_relative '../src/adaptibrew'

class TestBrewer < Test::Unit::TestCase

  def setup
    @brewer = Brewer.new
    @adaptibrew = Adaptibrew.new.refresh
  end

  def test_base_path
    assert_equal(Dir.pwd, @brewer.base_path)
  end

  # Don't really know how to test this one...
  def test_wait
    @brewer.wait(0.1)
    assert_true(true)
  end

  def test_manual_script
    @brewer.manual('python_tester')
    assert_equal("it worked", @brewer.out.first[1])
  end

end
