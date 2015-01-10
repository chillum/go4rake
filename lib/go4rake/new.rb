require 'rake/tasklib'
require 'yaml'
require 'zip'
require 'zip/filesystem'

# Rake tasks to cross-compile Go project and ZIP the binaries:
# `rake build`, `rake test` and `rake zip`.
#
# Usage: `require 'go4rake'` in `Rakefile`. Settings are specified in a YAML file: `go4rake.yml`.
#
# Example config: https://github.com/chillum/httpstress-go/blob/master/go4rake.yml
#
# Docs: https://github.com/chillum/go4rake/blob/master/README.md
#
# Offline copies of README and example config are also included in this gem.
class Go4Rake < ::Rake::TaskLib
  # Load configuration file and initialize Rake tasks for cross-compiling Go programs.
  def initialize(yml = 'go4rake.yml')
    begin
      @config = YAML.load_file(yml)
      tasks(@config, yml)
    rescue => e
      $stderr.puts("WARNING: Skipping `build` and `zip` tasks: #{e}")
    end
    # `build` and `zip` depend on config, `test` doesn't.
    task_test
  end

  # Initialize `build` and `zip` tasks.
  def tasks(cfg, yml)
    desc "Build this project for the platforms in #{yml}"
    task :build do
      cfg['platforms'].each { |os|
        if os['arch'].respond_to?('each')
          os['arch'].each { |arch|
            build(os['name'], arch)
          }
        else
          build(os['name'], os['arch'])
        end
      }
    end

    desc 'ZIP this project binaries'
    task :zip => [:build, :test] do
      cfg['out'] ||= '.' # Default to the current directory, if 'out' is not specified.

      cfg['platforms'].each { |os|
        if os['arch'].respond_to?('each')
          os['arch'].each { |arch|
            zip(os['name'], arch, cfg['out'], os['zip'] ? "#{os['zip']}_#{arch}" : "#{os['name']}_#{arch}")
          }
        else
          zip(os['name'], os['arch'], cfg['out'], os['zip'] || "#{os['name']}_#{os['arch']}")
        end
      }
    end
  end

  # Initialize `test` task.
  def task_test
    desc 'Run `go test` for the native platform'
    task :test do
      setenv(nil, nil)
      system('go test') || die('Tests')
    end
  end

  # Set GOARCH and GOOS.
  def setenv(os, arch)
    ENV['GOARCH'] = arch ? arch.to_s : nil
    ENV['GOOS']   = os
  end

  # Exit with an error.
  def die(task)
    abort("#{task} failed. Exiting") # Rake returns 1 in something fails.
  end

  # Execute `go install` for the specified os/arch.
  def build(os, arch)
    setenv(os, arch)
    puts("Building #{os}_#{arch}")
    system('go install') || die('Build')
  end

  # Zip the compiled files.
  def zip(os, arch, dir, file)
    setenv(os, arch)
    bin = `go list -f '{{.Target}}'`.chomp
    return unless bin
    zip_file = File.expand_path(dir) + '/' + file + '.zip'
    name     = File.basename(bin)

    Zip::File.open(zip_file, Zip::File::CREATE) do |zip|
      # `NOTICE` file is required by Apache license.
      begin
        zip.add('NOTICE', 'NOTICE') if File.exists?('NOTICE')
      rescue Zip::ZipEntryExistsError
        zip.replace('NOTICE', 'NOTICE')
      end

      # The executable file.
      begin
        zip.add(name, bin)
      rescue Zip::ZipEntryExistsError
        zip.replace(name, bin)
      end
      zip.file.chmod(0755, name)
    end
    puts("Wrote #{zip_file}")
  end
end
