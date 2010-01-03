
require 'ACDAConstants.rb'
require 'DiscPlugin.rb'

class DebugPlugin < DiscPlugin

def initialize(parameter)
end

def self.get_types()
    Hash.new
end

def self.add(disc)
  puts "DebugPlugin.add disc #{disc.get_value('Number')}"
end

def self.scan(disc, path)
  puts "DebugPlugin.scan disc #{disc.get_value('Number')} from #{path}"
end

def self.scan_file(disc, file)
  puts "DebugPlugin.scan_file disc #{disc.get_value('Number')} file #{file.name}"
end

def self.modify(disc)
  puts "DebugPlugin.modify disc #{disc.get_value('Number')}"
end

end

DiscPlugins.register(
    DiscPluginDefinition.new(
        'debug', 'Debug Information Plugin', 'Prints debug information about the scanning process.',
        DebugPlugin, true, true
    )
)
