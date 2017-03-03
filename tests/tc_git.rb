require 'test/unit'
require 'fileutils'
require_relative '../src/git'



class TestGit < Test::Unit::TestCase
  def setup
    if Dir.exists?('../adaptibrew')
      FileUtils.rm_rf('../adaptibrew')
      puts "Adaptibrew directory deleted for git testing"
    end
  end

  def test_clone_repo
    raise "Error! Adaptibrew directory is already there! \nThis won't be a problem at run time, but there may be issues with testing." unless !Dir.exists?('../adaptibrew')
    clone_repo('/Users/Luke/Desktop/ruby_brewer/')
    assert_true(Dir.exists?('../adaptibrew'))
  end

end
