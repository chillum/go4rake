# frozen_string_literal: true

require 'rake/tasklib'
require 'yaml'
require 'zip/filesystem'

# Rake tasks to cross-compile Go project and ZIP the binaries:
# `rake build`, `rake zip`, `rake test` and `rake clean`.
#
# Usage: `require 'go4rake'` in `Rakefile`. Settings are specified in a YAML file: `go4rake.yml`.
#
# Example config: https://github.com/chillum/go4rake/blob/master/examples/go4rake.yml
#
# Docs: https://github.com/chillum/go4rake/blob/master/README.md
#
# Offline copies of README and example config are also included in this gem.
#
class Go4Rake < ::Rake::TaskLib
  # Load configuration file and initialize Rake tasks for cross-compiling Go programs.
  def initialize(yml = 'go4rake.yml')
    super()
    begin
      @yaml_file = yml
      @config = YAML.load_file(@yaml_file)
      @config['out'] ||= '~/Downloads' # Default to ~/Downloads, if 'out' is not specified.

      init_tasks
    rescue(Errno::ENOENT) => e
      warn "WARNING: Skipping `build` and `zip` tasks: #{e}"
    end
    # `build`, `zip` and `clean` depend on config, `test` doesn't.
    task_test
  end

  private

  def init_tasks
    task_build
    task_zip
    task_clean
  end

  # Initialize `build`, `zip` and `clean` tasks.
  def task_build
    desc "Build this project for the platforms in #{@yaml_file}"
    task :build do
      @config['platforms'].each { |os|
        if os['arch'].respond_to?('each')
          os['arch'].each { |arch|
            build(os['name'], arch)
          }
        else
          build(os['name'], os['arch'])
        end
      }
    end
  end

  def task_zip
    desc 'ZIP this project binaries'
    task zip: %i[build test] do
      @config['platforms'].each { |os|
        if os['arch'].respond_to?('each')
          os['arch'].each { |arch|
            zip(os['name'], arch, @config['out'], @config['files'],
                os['zip'] ? "#{os['zip']}_#{arch}" : "#{os['name']}_#{arch}")
          }
        else
          zip(os['name'], os['arch'], @config['out'], @config['files'],
              os['zip'] || "#{os['name']}_#{os['arch']}")
        end
      }
    end
  end

  def task_clean
    desc 'Delete ZIP files'
    task :clean do
      @config['platforms'].each { |os|
        if os['arch'].respond_to?('each')
          os['arch'].each { |arch|
            clean(@config['out'], os['zip'] ? "#{os['zip']}_#{arch}" : "#{os['name']}_#{arch}")
          }
        else
          clean(@config['out'], os['zip'] || "#{os['name']}_#{os['arch']}")
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
  def zip(os, arch, dir, files, file)
    setenv(os, arch)
    bin = `go list -f '{{.Target}}'`.chomp.delete_prefix("'").delete_suffix("'")
    return unless bin

    zip_file = "#{File.expand_path(dir)}/#{file}.zip"
    name     = File.basename(bin)
    unless files
      files = []
      # `NOTICE` file is required by Apache license.
      files.push('NOTICE') if File.exist?('NOTICE')
    end

    File.delete(zip_file) if File.exist?(zip_file)
    Zip::File.open(zip_file, Zip::File::CREATE) do |zip|
      [*files].each { |i|
        t = File.basename(i)
        zip.add(t, i)
      }

      # The executable file.
      zip.add(name, bin)
      zip.file.chmod(0o755, name)
    end
    puts("Wrote #{zip_file}")
  end

  # Remove the ZIP file (specify path and basename).
  def clean(dir, file)
    zip_file = "#{File.expand_path(dir)}/#{file}.zip"
    return unless File.exist?(zip_file)

    puts("Removing #{zip_file}")
    File.delete(zip_file)
  end
end
