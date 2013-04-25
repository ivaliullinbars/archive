require 'ffi'

module Archive
  module LibArchive
    extend FFI::Library

    ffi_lib 'archive'

    ARCHIVE_OK      = 0
    ARCHIVE_EOF     = 1
    ARCHIVE_RETRY   = -10
    ARCHIVE_WARN    = -20
    ARCHIVE_FAILED  = -25
    ARCHIVE_FATAL   = -30

    ARCHIVE_EXTRACT_OWNER           = 0x0001
    ARCHIVE_EXTRACT_PERM            = 0x0002
    ARCHIVE_EXTRACT_TIME            = 0x0004

    attach_function :archive_read_new, [], :pointer
    attach_function :archive_write_disk_new, [], :pointer
    attach_function :archive_write_disk_set_options, [:pointer, :int], :void
    attach_function :archive_read_support_format_tar, [:pointer], :void
    attach_function :archive_read_support_format_gnutar, [:pointer], :void
    attach_function :archive_read_support_format_zip, [:pointer], :void

    def self.enable_input_formats(arg)
      archive_read_support_format_gnutar(arg)
      archive_read_support_format_zip(arg)
      archive_read_support_format_zip(arg)
      enable_input_compression(arg)
    end

    begin
      attach_function :archive_read_support_filter_all, [:pointer], :void
      def self.enable_input_compression(arg)
        archive_read_support_filter_all(arg)
      end
    rescue FFI::NotFoundError
      attach_function :archive_read_support_compression_all, [:pointer], :void
      def self.enable_input_compression(arg)
        archive_read_support_compression_all(arg)
      end
    end

    attach_function :archive_read_open_filename, [:pointer, :string, :size_t], :int
    attach_function :archive_error_string, [:pointer], :string
    attach_function :archive_read_next_header, [:pointer, :pointer], :int
    attach_function :archive_entry_pathname, [:pointer], :string
    attach_function :archive_write_header, [:pointer, :pointer], :int
    attach_function :archive_write_finish_entry, [:pointer], :int
    attach_function :archive_read_close, [:pointer], :void
    begin
      attach_function :archive_read_free, [:pointer], :void
    rescue FFI::NotFoundError
      attach_function :archive_read_finish, [:pointer], :void
      def self.archive_read_free(arg)
        archive_read_finish(arg)
      end
    end
    attach_function :archive_read_data_block, [:pointer, :pointer, :pointer, :pointer], :int
    attach_function :archive_write_data_block, [:pointer, :pointer, :size_t, :long_long], :int
  end
end
