require 'helper'

class TestExtract < ArchiveTestCase
  include FileUtils

  def setup
    @klass = Archive::Extract
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
    %w[zip tar.gz tar.bz2 iso].each do |ext|
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

  def test_obscene_multithreading
    %w[zip tar.gz tar.bz2 iso].each do |ext|
      thr = (1..10).map do
        Thread.new do
          extract_tmp("test/data/libarchive.#{ext}")
        end
      end

      path = nil

      thr.each do |t|
        begin
          path = t.value
          assert(path)
          full_dir = File.join(path, "libarchive")
          assert(File.directory?(full_dir))
          assert_no_difference("test/data/libarchive", full_dir)
        ensure
          unless !path or path.empty? or path == '/' or path == Dir.pwd
            rm_rf(path)
          end
        end
      end
    end
  end
end
