require 'bundler/setup'

if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start do
    add_filter '/test/'
  end
end

require 'archive'
require 'tempfile'
require 'fileutils'
require 'find'
require 'minitest'

class ArchiveTestCase < MiniTest::Test

  def get_files(dir)
    files = []
    Find.find(dir) do |path|
      files.push(path) if File.file?(path)
    end
    return files
  end

  def compress_dir(filename, dir, args)
    Archive::Compress.new(filename, args).compress(get_files(dir))
  end

  def extract_tmp(filename)
    dir = Dir.mktmpdir
    Archive::Extract.new(filename, dir).extract
    return dir
  end

  def assert_no_difference(path1, path2)
    args = %w[diff -rq] + [path1, path2]
    system(*args)
    assert_equal(0, $?.exitstatus)
  end
end

require 'minitest/autorun'
