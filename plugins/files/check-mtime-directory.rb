#!/usr/bin/env ruby
#
# Checks a file pattern's mtimes and alerts if any exceed
# ===
#
# DESCRIPTION:
#   This plugin checks a given file's modified time.
#
# OUTPUT:
#   plain-text
#
# PLATFORMS:
#   linux
#   bsd
#
# DEPENDENCIES:
#   sensu-plugin Ruby gem
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'fileutils'

# Check Mtimes on file pattern
class MtimeDirectory < Sensu::Plugin::Check::CLI
  option :file,
    :description => 'File pattern to check',
    :short => '-f FILES',
    :long => '--file FILES'

  option :warning_age,
    :description => 'Warn if any mtime greater than provided age in seconds',
    :short => '-w SECONDS',
    :long => '--warning SECONDS'

  option :critical_age,
    :description => 'Critical if any mtime greater than provided age in seconds',
    :short => '-c SECONDS',
    :long => '--critical SECONDS'

  def run_check(type, f)
    age = Time.now.to_i - File.mtime(f).to_i
    to_check = config["#{type}_age".to_sym].to_i
    if to_check > 0 && age >= to_check
      send(type, "file #{f} is #{age - to_check} seconds past #{type}")
    end
  end

  def run
    unknown 'No files provided' unless config[:file]
    unknown 'No warn or critical age specified' unless config[:warning_age] || config[:critical_age]
    files = Dir.glob(config[:file])
    if files.empty?
      ok 'no files older'
    else
      files.each do |f|
        run_check(:critical, f) || run_check(:warning, f)
      end
      ok
    end
  end
end
