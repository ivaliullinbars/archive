require 'ffi'

module Archive # :nodoc:
  module LibArchive # :nodoc:
    #--
    # this is necessary to pass rdoc's coverage tests
    #++
    module FFI # :nodoc:
      module Library # :nodoc:
      end
    end

    extend ::FFI::Library # :nodoc:

    #
    # needed by archiving entry functions
    #
    ffi_lib ::FFI::Library::LIBC

    begin
      attach_function :stat64, [:string, :pointer], :int
      def self.stat(string, pointer) # :nodoc:
        stat64(string, pointer)
      end
    rescue ::FFI::NotFoundError
      attach_function :stat, [:string, :pointer], :int
    end

    ffi_lib 'archive'

    ARCHIVE_OK      = 0     # :nodoc:
    ARCHIVE_EOF     = 1     # :nodoc:
    ARCHIVE_RETRY   = -10   # :nodoc:
    ARCHIVE_WARN    = -20   # :nodoc:
    ARCHIVE_FAILED  = -25   # :nodoc:
    ARCHIVE_FATAL   = -30   # :nodoc:

    ARCHIVE_EXTRACT_OWNER           = 0x0001 # :nodoc:
    ARCHIVE_EXTRACT_PERM            = 0x0002 # :nodoc:
    ARCHIVE_EXTRACT_TIME            = 0x0004 # :nodoc:

    attach_function :archive_read_new, [], :pointer
    attach_function :archive_read_disk_new, [], :pointer
    attach_function :archive_read_disk_set_standard_lookup, [:pointer], :void
    attach_function :archive_write_new, [], :pointer
    attach_function :archive_write_disk_new, [], :pointer
    attach_function :archive_write_disk_set_options, [:pointer, :int], :void
    attach_function :archive_read_support_format_tar, [:pointer], :void
    attach_function :archive_read_support_format_gnutar, [:pointer], :void
    attach_function :archive_read_support_format_zip, [:pointer], :void

    def self.enable_input_formats(arg) # :nodoc:
      archive_read_support_format_gnutar(arg)
      archive_read_support_format_zip(arg)
      archive_read_support_format_zip(arg)
      enable_input_compression(arg)
    end

    attach_function :archive_write_set_format_ustar, [:pointer], :void
    attach_function :archive_write_set_format_zip, [:pointer], :void

    def self.enable_output_archive(arg, type=:tar)
      case type
      when :tar
        archive_write_set_format_ustar(arg)
      when :zip
        archive_write_set_format_zip(arg)
      end
    end

    begin
      attach_function :archive_read_support_filter_all, [:pointer], :void
      def self.enable_input_compression(arg) # :nodoc:
        archive_read_support_filter_all(arg)
      end
    rescue ::FFI::NotFoundError
      attach_function :archive_read_support_compression_all, [:pointer], :void
      def self.enable_input_compression(arg) # :nodoc:
        archive_read_support_compression_all(arg)
      end
    end

    begin
      attach_function :archive_write_add_filter_gzip, [:pointer], :void
      attach_function :archive_write_add_filter_bzip2, [:pointer], :void
      def self.enable_output_compression(arg, type=:gzip) # :nodoc:
        case type
        when :gzip
          archive_write_add_filter_gzip(arg)
        when :bzip2
          archive_write_add_filter_bzip2(arg)
        end
      end
    rescue ::FFI::NotFoundError
      attach_function :archive_write_set_compression_gzip, [:pointer], :void
      attach_function :archive_write_set_compression_bzip2, [:pointer], :void
      def self.enable_output_compression(arg, type=:gzip) # :nodoc:
        case type
        when :gzip
          archive_write_set_compression_gzip(arg)
        when :bzip2
          archive_write_set_compression_bzip2(arg)
        end
      end
    end

    attach_function :archive_read_open_filename, [:pointer, :string, :size_t], :int
    attach_function :archive_write_open_filename, [:pointer, :string], :int

    attach_function :archive_entry_new, [], :pointer
    attach_function :archive_entry_free, [:pointer], :void
    attach_function :archive_read_disk_entry_from_file, [:pointer, :pointer, :int, :pointer], :void

    attach_function :archive_error_string, [:pointer], :string
    attach_function :archive_read_next_header, [:pointer, :pointer], :int
    attach_function :archive_write_header, [:pointer, :pointer], :int
    attach_function :archive_write_finish_entry, [:pointer], :int
    attach_function :archive_read_close, [:pointer], :void
    attach_function :archive_write_close, [:pointer], :void

    begin
      attach_function :archive_read_free, [:pointer], :void
      attach_function :archive_write_free, [:pointer], :void
    rescue ::FFI::NotFoundError
      attach_function :archive_read_finish, [:pointer], :void
      def self.archive_read_free(arg) # :nodoc:
        archive_read_finish(arg)
      end

      attach_function :archive_write_finish, [:pointer], :void
      def self.archive_write_free(arg) # :nodoc:
        archive_write_finish(arg)
      end
    end

    attach_function :archive_read_data_block, [:pointer, :pointer, :pointer, :pointer], :int
    attach_function :archive_write_data_block, [:pointer, :pointer, :size_t, :long_long], :int
    attach_function :archive_write_data, [:pointer, :pointer, :size_t], :void

    attach_function :archive_entry_pathname, [:pointer], :string
    attach_function :archive_entry_set_pathname, [:pointer, :string], :void
  end
end
