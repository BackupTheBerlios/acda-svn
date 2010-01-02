
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

def self.get_plugin(id)
	if ! @@plugins[id]
		raise ArgumentError, "Unknown Repository '#{id}'"
	end

	return @@plugins[id].plugin
end

def self.get_plugins()
    return @@plugins
end

def self.add_disc(disc)
  @@plugins.each() { |name, plugin|
    plugin.plugin.add(disc)
  }
end

def self.scan_disc(disc, path)
  @@plugins.each() { |name, plugin|
    plugin.plugin.scan(disc, path)
  }
end

def self.scan_file(disc, file)
  @@plugins.each() { |name, plugin|
    plugin.plugin.scan_file(disc, file)
  }
end

def self.modify_idsc(disc)
  @@plugins.each() { |name, plugin|
    plugin.plugin.modify(disc)
  }
end

end

if __FILE__ == $0
  require 'ACDAConstants.rb'

	DiscPlugins.load_plugins(ACDAConstants.disc_plugins_dir)
	DiscPlugins.list_plugins().each do |id, info|
		puts info
	end
end
	
