require 'test/unit'
require_relative '../src/git'

class TestGit < Test::Unit::TestCase

  def setup
    @manager = RepoManager.new
  end

  # `refresh` calls both `clone` and `clear`. oh that sweet, sweet code coverage
  def test_refresh
    @manager.refresh
    assert_true(Dir.exists?('adaptibrew'))
  end

  # Testing a not-so-failed case of cloning
  def test_clone_will_skip_if_repo_present
    @manager.refresh
    assert_equal("Adaptibrew is already there. Cloning skipped.", @manager.clone)
  end

  def teardown
    @manager.refresh
  end

end
