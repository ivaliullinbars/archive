module Archive
  class Extract

    attr_reader :filename
    attr_reader :dir

    def initialize(filename, dir=Dir.pwd)
      unless File.exist?(filename)
        raise ArgumentError, "File '#{filename}' does not exist!"
      end

      unless File.directory?(dir)
        raise ArgumentError, "Directory '#{dir}' does not exist!"
      end

      @filename = filename
      @dir      = dir

      @extract_flags =
        LibArchive::ARCHIVE_EXTRACT_PERM |
        LibArchive::ARCHIVE_EXTRACT_TIME
    end

    def extract(verbose=false)
      create_io_objects
      open_file

      header_loop(verbose)

      close
    end

    protected

    def create_io_objects
      @in = LibArchive.archive_read_new
      @out = LibArchive.archive_write_disk_new
      LibArchive.archive_write_disk_set_options(@out, @extract_flags)
      @entry = FFI::MemoryPointer.new :pointer
      LibArchive.enable_input_formats(@in)
    end

    def open_file
      LibArchive.archive_read_open_filename(@in, @filename, 10240)
    end

    def header_loop(verbose)
      while ((result = LibArchive.archive_read_next_header(@in, @entry)) != LibArchive::ARCHIVE_EOF)

        entry_pointer = @entry.get_pointer(0)

        if result != LibArchive::ARCHIVE_OK
          raise LibArchive.archive_error_string(result)
        end

        full_path = File.join(@dir, LibArchive.archive_entry_pathname(entry_pointer))
        LibArchive.archive_entry_set_pathname(entry_pointer, full_path)

        # TODO return value maybe?
        puts LibArchive.archive_entry_pathname(entry_pointer) if verbose

        if ((result = LibArchive.archive_write_header(@out, entry_pointer)) != LibArchive::ARCHIVE_OK)
          raise LibArchive.archive_error_string(result)
        end

        unpack_loop

        LibArchive.archive_write_finish_entry(@out)
      end
    end

    def unpack_loop
      loop do
        buffer = FFI::MemoryPointer.new :pointer, 1
        size   = FFI::MemoryPointer.new :size_t
        offset = FFI::MemoryPointer.new :long_long

        result = LibArchive.archive_read_data_block(@in, buffer, size, offset)

        break if result == LibArchive::ARCHIVE_EOF

        unless result == LibArchive::ARCHIVE_OK
          raise LibArchive.archive_error_string(result)
        end

        result = LibArchive.archive_write_data_block(@out, buffer.get_pointer(0), size.read_ulong_long, offset.read_long_long);

        if result != LibArchive::ARCHIVE_OK
          raise LibArchive.archive_error_string(result)
        end
      end
    end

    def close
      LibArchive.archive_read_close(@in)
      LibArchive.archive_read_free(@in)
      LibArchive.archive_write_close(@out)
      LibArchive.archive_write_free(@out)
      @in = nil
      @out = nil
      @entry = nil
    end
  end
end
