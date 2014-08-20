# A script to cross-compile Go project and ZIP the binaries.
#
# Settings are specified in a YAML file: go4rake.yml.
#
# Example config: https://github.com/chillum/httpstress-go/go4rake.yml
# `name` is OS name, `arch` is arch and `zip` is ZIP file name (optional).
# `arch` is appended to file name if `arch` is a list.
#
# If `out` is specified, ZIP files will appear in the specified directory;
# if not, they will be in current directory.

# Copyright 2014 Vasily Korytov
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'rake/tasklib'
require 'yaml'

class Go4Rake
  class RakeTask < ::Rake::TaskLib
    def initialize(*args)

      begin
        yml = 'go4rake.yml'
        config = YAML.load_file yml

        desc "Build this project for the platforms in #{yml}"
        task :build do
          config['platforms'].each { |os|
            if os['arch'].respond_to?('each')
              os['arch'].each { |arch| build os['name'], arch }
            else
              build os['name'], os['arch']
            end
          }
        end

        desc 'ZIP this project binaries'
        task :zip => [:build, :test] do
          unless config['out']
            config['out'] = '.' # Default to the current directory, if 'out' is not specified.
          end

          config['platforms'].each { |os|
            if os['arch'].respond_to?('each')
              os['arch'].each { |arch| zip os['name'], arch, config['out'], os['zip'] ? \
                "#{os['zip']}_#{arch}" : "#{os['name']}_#{arch}" }
            else
              zip os['name'], os['arch'], config['out'], os['zip'] || "#{os['name']}_#{os['arch']}"
            end
          }
        end
      rescue
        puts "Warning: unable to load #{yml}. Disabling `build` and `zip` tasks."
      end

      desc 'Run `go test` for the native platform'
      task :test do
        setenv nil, nil
        unless system('go test'); die 'Tests' end
      end

      def setenv os, arch
        ENV['GOARCH'] = arch ? arch.to_s : nil
        ENV['GOOS']   = os
      end

      def die task
        puts "#{task} failed. Exiting"
        exit 1 # Rake returns 1 if something fails.
      end

      def build os, arch
        setenv os, arch
        puts "Building #{os}_#{arch}"
        unless system('go install'); die 'Build' end
      end

      def zip os, arch, dir, file
        setenv os, arch

        if system("zip -qj #{dir}/#{file}.zip #{`go list -f '{{.Target}}'`}")
          puts "Wrote #{dir}/#{file}.zip"
        end
      end

    end
  end
end

Go4Rake::RakeTask.new
