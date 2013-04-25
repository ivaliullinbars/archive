require 'archive'

include Archive

files = Dir["**/*"].reject { |f| !File.file?(f) }

stat = FFI::MemoryPointer.new :pointer
buff = FFI::Buffer.new 1024

@archive = LibArchive.archive_write_new
LibArchive.enable_output_compression(@archive)
LibArchive.enable_output_archive(@archive)
LibArchive.archive_write_open_filename(@archive, "test.tar.gz")
@disk = LibArchive.archive_read_disk_new
LibArchive.archive_read_disk_set_standard_lookup(@disk)

files.each do |file|
  puts file
  entry = LibArchive.archive_entry_new

  LibArchive.archive_entry_set_pathname(entry, file)
  LibArchive.stat(file, stat)
  LibArchive.archive_read_disk_entry_from_file(@disk, entry, -1, stat)
  LibArchive.archive_write_header(@archive, entry)
  File.open(file, 'r') do |f|
    loop do
      str = f.read(1024)
      break unless str and str.length > 0
      str.force_encoding("BINARY")
      buff.put_bytes(0, str)
      LibArchive.archive_write_data(@archive, buff, str.length)
    end
  end

  LibArchive.archive_entry_free(entry)
end

LibArchive.archive_read_close(@disk)
LibArchive.archive_read_free(@disk)
LibArchive.archive_write_close(@archive)
LibArchive.archive_write_free(@archive)
