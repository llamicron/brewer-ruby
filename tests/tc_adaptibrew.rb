require 'test/unit'
require_relative '../src/adaptibrew'

class TestGit < Test::Unit::TestCase

  def setup
    @adaptibrew = Adaptibrew.new
  end

  # `refresh` calls both `clone` and `clear`. oh that sweet, sweet code coverage
  def test_refresh
    @adaptibrew.refresh
    assert_true(Dir.exists?('adaptibrew'))
  end

  # Testing a not-so-failed case of cloning
  def test_clone_will_skip_if_repo_present
    @adaptibrew.refresh
    assert_equal("Adaptibrew is already there. Cloning skipped.", @adaptibrew.clone)
  end

  def teardown
    @adaptibrew.refresh
  end

end
