
require 'ftools'
require 'ACDAConstants.rb'
require 'fileutils.rb'
require 'exceptions.rb'

class ACDAConfig
	attr_reader :path
	attr_reader :values
	attr_accessor :keys

	def initialize(path, keys = nil)
		@keys = %w#plugin_dir plugin plugin_param disc_plugin_dir#

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
					raise ParseError, "Unknown key #{key} in config file"
				end

				@values[key] = value
			end
		end

		@values
	end

	def createDefaultConfig(path)
        return if File.file?(path)

        default=ACDAConstants.acda_home + '/examples/acda.cfg'
        unless File.file?(default)
            raise FileNotFoundError, "Could not find default config "+
                                     "file '#{default}'\n"
        end
        unless File.directory?(File.dirname(path))
            File.makedirs(File.dirname(path))
        end
		FileUtils.copy(default, path)
	end
end

if $0 == __FILE__
conf = ACDAConfig.new(ACDAConstants.acda_config)
puts conf.values.inspect
end
