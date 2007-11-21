
class DiscPluginDefinition
	attr_accessor :id, :name, :desc, :plugin, :scan_plugin, :modify_plugin

	def initialize(id, name, desc, plugin, scan_plugin, modify_plugin)
		@id		= id
		@name 	= name
		@desc  	= desc
		@plugin = plugin
		@scan_plugin   = scan_plugin
		@modify_plugin = modify_plugin
	end

	def to_s()
		s = "#{@name} [#{@id}]"
        s += " scanning " if @scan_plugin
        s += " modify" if @modify_plugin
        s += ": #{@desc}"
        return s
	end
end

class DiscPlugins
	@@plugins = Hash.new

def self.register(definition)
	@@plugins[definition.id] = definition;
end

def self.load_plugins(plugins_dir)
    unless File.directory?(plugins_dir)
        raise ArgumentError, "Plugin path '#{plugins_dir}' is not existing or "+
                             "not a directory."
    end

	Dir[plugins_dir + "/*.rb"].each do |pluginfile|
		load pluginfile
	end
end

def self.get_types()
    types = Hash.new
    @@plugins.each { |name, plugin|
        plugin.plugin.get_types().each { |a,b| types[a] = b }
    }
    return types
end

def self.list_plugins()
	@@plugins
end

def self.get_plugin(id, parameter = nil)
	if ! @@plugins[id]
		raise ArgumentError, "Unknown Repository '#{id}'"
	end

	return @@plugins[id].plugin.new(parameter)
end

def self.get_plugins()
    return @@plugins
end
end

if __FILE__ == $0
    require 'ACDA.rb'

	DiscPlugins.load_plugins(ACDA.disc_plugins_dir)
	DiscPlugins.list_plugins().each do |id, info|
		puts info
	end
end
	
