## go4rake is a Rake helper for cross-compiling Go programs

It provides the following tasks:

* `rake build` for cross-compiling for the specified architectures
* `rake zip` command for making ZIP files that contain binary builds
* `rake test` for running tests for the native architecture

`zip` depends on `build` and `test` (in that order).

`build` uses `go install`, `test` uses `go test`.

The reason only the native runtime is supported in `test` is that `go test` for a different operating system does not work. That's a pity.

Note: when used on Windows, ZIP files for Mac/Linux/Unix will contain
incorrect permissions (after extracting them one needs to do `chmod +x
executable_file`). Probably, that means, we need a different archiver
on Windows (7-zip? Don't know).

### To install and use go4rake you need:

* Go cross-compilation toolchain for all the platforms, you need.  
  (Mac and [Homebrew](http://brew.sh/) users can run `brew install go --cross-compile-common`
  or `brew install go --cross-compile-all` for this, on other Unix and Windows you should
  [build Go from source](http://dave.cheney.net/2013/07/09/an-introduction-to-cross-compilation-with-go-1-1).)
* [Info-ZIP](http://www.info-zip.org/Zip.html) `zip` binary in path
  (ships with MacOS X and most Unix systems).
* Install [Ruby](https://www.ruby-lang.org). `rake` and `gem` come with is.
* Install go4rake: `gem install go4rake`.
* Enable go4rake in `Rakefile`: include `require 'go4rake'` in it (create the file, if missing).  
  (Unix users can do: `echo "require 'go4rake'" >> Rakefile`.)
* Specify your platforms in `go4rake.yml`. See below for configuration.
* Run `rake build` or `rake zip`.

### Configuration

`zip` and `build` tasks expect a YAML config, `go4rake.yml`. Say, we
have [this config](https://github.com/chillum/httpstress-go/blob/master/go4rake.yml).

This way, you run `rake zip` and you get these files containing the static binary files for all the specified platforms:

* win32.zip
* win64.zip
* linux_amd64.zip
* linux_i386.zip
* mac.zip

For each platform:

* `name` is OS name
* `arch` is arch
* `zip` is ZIP file name (optional)

Please note that:

* If `out` is specified, ZIP files will appear in the specified
  directory; if not, they will be in current directory
* `arch` is appended to the file name if `arch` is a list
