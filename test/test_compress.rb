require 'helper'

class TestCompress < ArchiveTestCase
  include FileUtils

  def setup
    @klass = Archive::Compress
  end

  def test_constructor
    obj = @klass.new("test")
    assert_equal("test", obj.filename)
    assert_equal(:tar, obj.type)
    assert_equal(:gzip, obj.compression)

    obj = @klass.new("test", :type => :tar)
    assert_equal("test", obj.filename)
    assert_equal(:tar, obj.type)
    assert_nil(obj.compression)

    obj = @klass.new("test", :type => :tar, :compression => :gzip)
    assert_equal("test", obj.filename)
    assert_equal(:tar, obj.type)
    assert_equal(:gzip, obj.compression)

    obj = @klass.new("test", :type => :tar, :compression => :bzip2)
    assert_equal("test", obj.filename)
    assert_equal(:tar, obj.type)
    assert_equal(:bzip2, obj.compression)

    obj = @klass.new("test", :type => :zip, :compression => :gzip)
    assert_equal("test", obj.filename)
    assert_equal(:zip, obj.type)
    assert_nil(obj.compression)
  end

  def test_basic_compress
    Dir.chdir("test/data") do
      [
        { :type => :tar },
        { :type => :tar, :compression => :gzip },
        { :type => :tar, :compression => :bzip2 },
        { :type => :zip }
      ].each do |args|
        Tempfile.open("archive-test") do |file|
          begin
            path = file.path
            file.close
            compress_dir(path, "libarchive", args)
            assert(File.exist?(path))
            assert(File.stat(path).size > 0)
            extracted = extract_tmp(path)
            assert_no_difference("libarchive", File.join(extracted, "libarchive"))
          ensure
            unless !extracted or extracted.empty? or extracted == '/' or extracted == Dir.pwd
              rm_rf(extracted)
            end
          end
        end
      end
    end
  end

  def test_obscene_multithreading
    Dir.chdir("test/data") do
      [
        { :type => :tar },
        { :type => :tar, :compression => :gzip },
        { :type => :tar, :compression => :bzip2 },
        { :type => :zip }
      ].each do |args|
        thr = (1..10).map do
          Thread.new do
            extracted = nil
            Tempfile.open("archive-test") do |file|
              path = file.path
              file.close
              compress_dir(path, "libarchive", args)
              assert(File.exist?(path))
              assert(File.stat(path).size > 0)
              extracted = extract_tmp(path)
            end
            extracted
          end
        end

        path = nil

        begin
          thr.each do |t|
            path = t.value
            assert_no_difference("libarchive", File.join(path, "libarchive"))
            rm_rf(path)
          end
        ensure
          unless !path or path.empty? or path == '/' or path == Dir.pwd
            rm_rf(path)
          end
        end
      end
    end
  end
end
