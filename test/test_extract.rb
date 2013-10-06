require 'helper'

class TestExtract < ArchiveTestCase
  include FileUtils

  def setup
    @klass = Archive::Extract
  end

  def test_constructor
    assert_raises(ArgumentError) { @klass.new("/nonexistent.tar.gz", "/") }
    assert_raises(ArgumentError) { @klass.new("test/data/test.zip", "/nonexistent") }
    obj = @klass.new("test/data/test.zip", Dir.pwd)
    assert_equal("test/data/test.zip", obj.filename)
    assert_equal(Dir.pwd, obj.dir)
  end

  def test_basic_extraction
    path = nil
    formats = %w[zip tar.gz tar.bz2 iso]

    formats.each do |ext|
      path = extract_tmp("test/data/test.#{ext}")
      assert(File.directory?(path))
      assert_no_difference(path, "test/data/test_archive")
      rm_rf(path)
    end
  ensure
    unless !path or path.empty? or path == '/' or path == Dir.pwd
      rm_rf(path)
    end
  end

  def test_obscene_multithreading
    formats = %w[zip tar.gz tar.bz2 iso]

    formats.each do |ext|
      thr = (1..10).map do
        Thread.new do
          extract_tmp("test/data/test.#{ext}")
        end
      end

      path = nil

      thr.each do |t|
        begin
          path = t.value
          assert(path)
          assert(File.directory?(path))
          assert_no_difference("test/data/test_archive", path)
        ensure
          unless !path or path.empty? or path == '/' or path == Dir.pwd
            rm_rf(path)
          end
        end
      end
    end
  end
end
