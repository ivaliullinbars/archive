# 0.0.6 (03/08/2014)
  * Upgrade FFI to 1.9.3 -- patch by esbeka
# 0.0.5 (01/21/2014)
  * `Archive::LibArchive.linked_archive_library` is an accessor for the dynamic library as a string
# 0.0.4 (10/10/2013)
  * Several fixes around hardlinks.
  * Better support for OS X! Will use homebrew or macports' libarchive if
    available so you can use a recent version.
# 0.0.3 (09/15/2013)
  * ISO support on linux systems -- Thanks David Lutterkort!
# 0.0.2 (05/02/2013)
  * Better memory management; heap corruption issue that wasn't showing up in tests.
  * Fixes for FreeBSD 9
  * Ensure `Archive.get_files` is protected properly (injekt)
# 0.0.1 (04/26/2013)
  * First release!
