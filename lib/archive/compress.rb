module Archive
  class Compress
    attr_reader :filename
    attr_reader :type
    attr_reader :compression

    BUFSIZE = 32767

    def initialize(filename, args={ :type => :tar, :compression => :gzip })
      @filename     = filename
      @type         = args[:type] || :tar
      @compression  = args[:compression]

      if type == :zip
        @compression = nil
      end
    end

    def compress(files, verbose=false)
      if files.any? { |f| !File.file?(f) }
        raise ArgumentError, "Files supplied must all be real, actual files -- not directories or symlinks."
      end

      configure_archive
      compress_files(files, verbose)
      free_archive
    end

    protected

    def configure_archive
      @archive = LibArchive.archive_write_new
      LibArchive.enable_output_compression(@archive, @compression)
      LibArchive.enable_output_archive(@archive, @type)
      LibArchive.archive_write_open_filename(@archive, @filename)
      @disk = LibArchive.archive_read_disk_new
      LibArchive.archive_read_disk_set_standard_lookup(@disk)
    end

    def compress_files(files, verbose)
      stat = FFI::MemoryPointer.new :pointer
      buff = FFI::Buffer.new BUFSIZE

      files.reject { |f| f == filename }.each do |file|
        next if file == filename

        # TODO return value maybe?
        puts file if verbose

        entry = LibArchive.archive_entry_new

        LibArchive.archive_entry_set_pathname(entry, file)
        LibArchive.stat(file, stat.get_pointer(0))
        LibArchive.archive_read_disk_entry_from_file(@disk, entry, -1, stat.get_pointer(0))
        LibArchive.archive_write_header(@archive, entry)

        File.open(file, 'r') do |f|
          loop do
            str = f.read(BUFSIZE)
            break unless str and str.length > 0
            str.force_encoding("BINARY")
            buff.put_bytes(0, str)
            LibArchive.archive_write_data(@archive, buff, str.length)
          end
        end

        LibArchive.archive_entry_free(entry)
      end
    end

    def free_archive
      LibArchive.archive_read_close(@disk)
      LibArchive.archive_read_free(@disk)
      LibArchive.archive_write_close(@archive)
      LibArchive.archive_write_free(@archive)
    end
  end
end
