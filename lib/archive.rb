require 'archive/version'
require 'archive/libarchive'
require 'archive/extract'
require 'archive/compress'

module Archive
  def self.extract(filename, dir=Dir.pwd)
    Archive::Extract.new(filename, dir).extract
  end

  def self.extract_and_print(filename, dir=Dir.pwd)
    Archive::Extract.new(filename, dir).extract(true)
  end

  def self.compress(filename, dir=Dir.pwd, args={ :type => :tar, :compression => :gzip })
    Archive::Compress.new(filename, args).compress(get_files(dir))
  end

  def self.compress_and_print(filename, dir=Dir.pwd, args={ :type => :tar, :compression => :gzip })
    Archive::Compress.new(filename, args).compress(get_files(dir), true)
  end

  protected

  def self.get_files(dir)
    require 'find'

    files = []

    Find.find(dir) do |path|
      files.push(path) if File.file?(path)
    end

    return files
  end
end
