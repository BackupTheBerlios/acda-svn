
require 'ACDAConstants.rb'
require 'DiscPlugin.rb'
require 'Type.rb'

class DefaultPlugin < DiscPlugin

def initialize(parameter)
end

def self.get_types()
    return Hash.new
end

def self.add(disc)
end

def self.scan(disc, path)
end

def self.scan_file(disc, file)
end

def self.modify(disc)
end

end

DiscPlugins.register(
    DiscPluginDefinition.new(
        'default', 'Default Types plugin', 'Plugin to register the default types.',
        DefaultPlugin, false, false
    )
)
