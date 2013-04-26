require 'helper'
require 'tempfile'
require 'fileutils'

class TestExtract < MiniTest::Unit::TestCase
  include FileUtils

  def setup
    @klass = Archive::Extract
  end

  def extract_tmp(filename)
    dir = Dir.mktmpdir
    @klass.new(filename, dir).extract
    return dir
  end

  def assert_no_difference(path1, path2)
    args = %w[diff -rq] + [path1, path2]
    system(*args)
    assert_equal(0, $?.exitstatus)
  end

  def test_constructor
    assert_raises(ArgumentError) { @klass.new("/nonexistent.tar.gz", "/") }
    assert_raises(ArgumentError) { @klass.new("test/data/libarchive.zip", "/nonexistent") }
    obj = @klass.new("test/data/libarchive.zip", Dir.pwd)
    assert_equal("test/data/libarchive.zip", obj.filename)
    assert_equal(Dir.pwd, obj.dir)
  end

  def test_basic_extraction
    path = nil
    %w[zip tar.gz tar.bz2].each do |ext|
      path = extract_tmp("test/data/libarchive.#{ext}")
      full_dir = File.join(path, "libarchive")
      assert(File.directory?(full_dir))
      assert_no_difference(full_dir, "test/data/libarchive")
      rm_rf(path)
    end
  ensure
    unless !path or path.empty? or path == '/' or path == Dir.pwd
      rm_rf(path)
    end
  end
end
