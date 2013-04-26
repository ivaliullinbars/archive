require 'archive'

Dir.chdir("test/data")
Archive.compress_and_print("test.tar.gz", "libarchive")
