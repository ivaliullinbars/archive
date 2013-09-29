# Archive

Archive is a simple and effective way to utilize libarchive, the slicing,
dicing, all-in-one BSD archiving toolkit. It keeps it simple by only handling a
common subset of archive types:

* tar
  * uncompressed
  * gzipped
  * bzip2'd
* zip (uncompressed, binary-only)
* iso9660 (read-only)

## Installation

Add this line to your application's Gemfile:

    gem 'archive'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install archive

You will also need a copy of 'libarchive'. This comes with some operating
systems (OS X, mingw builds on windows) and others you have to use your package
manager to install them. It is not required to install the gem, but to use it.

You will also need a compiler to install FFI.

## Usage

```ruby
# stuff the contents of $HOME in /tmp/tmp.tar.gz
Archive.compress("/tmp/tmp.tar.gz", ENV["HOME"])
# same thing, only a zip file
Archive.compress("/tmp/tmp.zip", ENV["HOME"], :type => :zip)
# now bzip2
Archive.compress("/tmp/tmp.tar.bz2", ENV["HOME"], :type => :tar, :compression => :bzip2)

# OOP interface:
ac = Archive::Compress.new("/tmp/my_files.tar.gz", :type => :tar, :compression => :gzip)
ac.compress(["some", "files"])

# let's extract those files
require 'fileutils'
FileUtils.mkdir_p("/tmp/woot")
# this works for any kind of archive we support -- no need to express which
# type
Archive.extract("/tmp/tmp.tar.gz", "/tmp/woot")

# OOP interface:
ae = Archive::Extract.new("/tmp/tmp.tar.gz", "/tmp/woot")
ae.extract
```

## Testing

Tests do not come with the gem because of file sizes of the archives and test
data in the repository.

Tests require bundler. Run `bundle exec rake test` to run the tests.

We have verified that archive works as intended on these platforms:

* Mac OS X 10.8, 10.9 (see notes on ISO support)
* Ubuntu Linux 12.04 LTS
* FreeBSD 9

And these Rubies:

* 1.9.3
* 2.0.0
* JRuby 1.7 with Java 7

Notes about the following platforms:

* On OS X iso formats are only supported if you have a 3.x version of
  libarchive, which OS X doesn't ship with. The code makes an attempt to pick
  the latest homebrew or macports libarchive, so if you use that packaging
  system, you can `brew install libarchive` or `port install libarchive` and it
  will "just work".
  * Alternatively, you can set `LIBARCHIVE_PATH` in your environment to your
    own build of libarchive 3.x which will also resolve this issue.

* SmartOS "base64 1.9.1". The version of libarchive they distribute via pkgsrc
	is broken, see this URL: 

  http://freebsd.1045724.n5.nabble.com/Extracting-tgz-file-Attempt-to-write-to-an-empty-file-td3910927.html

  Regardless, installing a newer libarchive by hand and setting
  `LIBARCHIVE_PATH` in your environment will likely fix this issue.

Please let us know if your operating system isn't working! It'll likely
complain about a part of a structure in a syscall called `stat` which varies
wildly on different POSIX systems. We just need to know what platform you're on
and how we can install it ourselves to move forward. Thanks!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
