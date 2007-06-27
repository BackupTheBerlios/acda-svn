
require 'DirTraverser.rb'
require 'ACDAFile.rb'

class DiscParser
	attr_reader :root
	attr_accessor :callback

	def initialize
		@root = nil
		@callback = nil
	end

	def parse(path)
		if not File.directory?(path)
			raise ArgumentError, "The specified path is not a directory"
		end
		if not File.readable?(path)
			raise ArgumentError, "The specified path is not readable"
		end

		traverser = DirTraverser.new(self)
		traverser.depthTraversal(path)
		return @root
	end

	def addDirectory(parent, path)
		file = ACDAFile.createFromPath(path)
		@callback.addDirectory(path) if @callback
		parent.addChild(file) if parent
		@root = file unless @root

		return file
	end

	def addFile(parent, path)
		file = ACDAFile.createFromPath(path)
		@callback.addFile(path) if @callback
		if parent
			raise ArgumentError, "The specified parent is not a directory" unless parent.directory?
			parent.addChild(file)
		end

		return file
	end
end

if $0 == __FILE__

p = DiscParser.new
puts p.parse('/tmp')

end
