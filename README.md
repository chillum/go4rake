## go4rake: Rake tasks for cross-compiling Go programs [![Gem Version](https://badge.fury.io/rb/go4rake.svg)](http://badge.fury.io/rb/go4rake)

This gem provides the following tasks:

* `rake build` for cross-compiling for the specified architectures
* `rake zip` command for making ZIP files that contain binary builds
* `rake test` for running tests for the native architecture

`zip` depends on `build` and `test` (in that order).

`build` uses `go install`, `test` uses `go test`.

The reason only the native runtime is supported in `test` is that `go test` for a different operating system does not work. That's a pity.

### To install and use go4rake you need:

* Go cross-compilation toolchain for all the platforms, you need.  
  (Mac and [Homebrew](http://brew.sh/) users can run `brew install go --cross-compile-common`
  or `brew install go --cross-compile-all` for this, on other Unix and Windows you should
  [build Go from source](http://dave.cheney.net/2013/07/09/an-introduction-to-cross-compilation-with-go-1-1).)
* Install [Ruby](https://www.ruby-lang.org). `gem` utility comes with it.
* Install go4rake: `gem install go4rake`.
* Enable go4rake in `Rakefile`: include `require 'go4rake'` in it (create the file, if missing).  
  (Unix users can do: `echo "require 'go4rake'" >> Rakefile`.)
* Specify your platforms in `go4rake.yml`. See below for configuration.
* Run `rake build` or `rake zip`.

### Configuration

`zip` and `build` tasks expect a YAML config, `go4rake.yml`. Say, we
have [this config](https://github.com/chillum/httpstress-go/blob/master/go4rake.yml).

This way, you run `rake zip` and you get the following ZIP files
containing the static binary builds in your `~/Downloads` directory:

* `win32.zip`
* `win64.zip`
* `linux_amd64.zip`
* `linux_386.zip`
* `mac.zip`

For each platform:

* `name` is OS name
* `arch` is arch
* `zip` is ZIP file name (optional)

Please note that:

* ZIP files include a `NOTICE` file, if it's found in the project directory
* If `out` is specified, ZIP files will appear in the specified
  directory; if not, they will be in current directory
* ZIP file permissions default to `0600`, this is due to
  [bug in rubyzip](https://github.com/rubyzip/rubyzip/issues/204)
* `arch` is appended to the file name if `arch` is a list
