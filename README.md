# Archive

Archive is a simple and effective way to utilize libarchive, the slicing,
dicing, all-in-one BSD archiving toolkit. It keeps it simple by only handling a
common subset of archive types:

* tar
  * uncompressed
  * gzipped
  * bzip2'd
* zip (uncompressed, binary-only)

## Installation

Add this line to your application's Gemfile:

    gem 'archive'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install archive

## Usage

Example of the easy API:

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
