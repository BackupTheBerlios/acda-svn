
class RepositoryDefinition
	attr_accessor :id, :name, :desc, :plugin, :path

	def initialize(id, name, desc, plugin, path = nil)
		@id		= id
		@name 	= name
		@desc  	= desc
		@plugin = plugin
		@path  	= path
	end

	def to_s()
		s  = "#{@name} [#{@id}]: #{@desc}"
		s += " #{@path}" if @path
		return s
	end
end

class Persistance
	@@plugins = Hash.new

def self.register(definition)
	@@plugins[definition.id] = definition;
end

def self.load_plugins(plugins_dir)
	Dir[plugins_dir + "/*.rb"].each do |pluginfile|
		load pluginfile
	end
end

def self.list_plugins()
	@@plugins
end

def self.get_plugin(id, parameter)
	if ! @@plugins[id]
		raise ArgumentError, "Unknown Repository '#{id}'"
	end

	return @@plugins[id].plugin.new(parameter)
end
end

if __FILE__ == $0
	Persistance.load_plugins()
	Persistance.list_plugins().each do |id, info|
		puts info
	end

	a = Persistance.get_plugin('xml', '$ACDA_USERDIR');
end
	
