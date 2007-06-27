
require 'ACDA.rb'
require 'fileutils.rb'

class ACDAConfig
	attr_reader :path
	attr_reader :values
	attr_accessor :keys

	def initialize(path, keys = nil)
		@keys = %w#plugin_dir plugin plugin_param#

		@path   = path
		@values = Hash.new
		@keys   = keys if keys

		unless File.exists?(path)
			createDefaultConfig(path)
		end

		parse(path)
	end

	def parse(path)
		File.open(path) do |file|
			while line = file.gets
				next unless line.size > 0
				next if line[0, 1] == '#'

				key, value = line.split('=', 2)
				key.strip!
				value.strip!

				unless @keys.include?(key)
					raise RuntimeError, "Unknown key #{key} in config file"
				end

				@values[key] = value
			end
		end

		@values
	end

	def createDefaultConfig(path)
		FileUtils.copy(ACDA.acda_home + "/examples/acda.cfg", path)
	end
end

if $0 == __FILE__
conf = ACDAConfig.new(ACDA.acda_config)
puts conf.values.inspect
end
