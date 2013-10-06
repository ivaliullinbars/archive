require 'helper'
require 'stringio'

class TestEasy < ArchiveTestCase
  include FileUtils

  def setup
    @klass = Archive
  end

  def test_compress
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

            Archive.compress(path, "test_archive", args)
            assert(File.exist?(path))
            assert(File.stat(path).size > 0)
            extracted = extract_tmp(path)
            assert_no_difference("test_archive", File.join(extracted, "test_archive"))
          ensure
            unless !extracted or extracted.empty? or extracted == '/' or extracted == Dir.pwd
              rm_rf(extracted)
            end
          end
        end
      end
    end
  end

  def test_compress_and_print
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

            orig_out = $stdout
            $stdout = StringIO.new('', 'w')
            Archive.compress_and_print(path, "test_archive", args)
            output = $stdout.string
            $stdout = orig_out
            assert(File.exist?(path))
            assert(File.stat(path).size > 0)
            refute_empty(output)
            extracted = extract_tmp(path)
            assert_no_difference("test_archive", File.join(extracted, "test_archive"))
          ensure
            unless !extracted or extracted.empty? or extracted == '/' or extracted == Dir.pwd
              rm_rf(extracted)
            end

            if orig_out
              $stdout = orig_out
            end
          end
        end
      end
    end
  end

  def test_extract
    begin
      path = nil

      %w[zip tar.gz tar.bz2].each do |ext|
        path = Dir.mktmpdir
        Archive.extract("test/data/test.#{ext}", path)
        assert(File.directory?(path))
        assert_no_difference(path, "test/data/test_archive")
        rm_rf(path)
      end
    ensure
      unless !path or path.empty? or path == '/' or path == Dir.pwd
        rm_rf(path)
      end
    end
  end

  def test_extract_and_print
    begin
      path = nil
      orig_out = nil

      %w[zip tar.gz tar.bz2].each do |ext|
        path = Dir.mktmpdir
        orig_out = $stdout
        $stdout = StringIO.new('', 'w')
        Archive.extract_and_print("test/data/test.#{ext}", path)
        output = $stdout.string
        $stdout = orig_out
        assert(File.directory?(path))
        assert_no_difference(path, "test/data/test_archive")
        refute_empty(output)
        rm_rf(path)
      end
    ensure
      unless !path or path.empty? or path == '/' or path == Dir.pwd
        rm_rf(path)
      end

      if orig_out
        $stdout = orig_out
      end
    end
  end
end
