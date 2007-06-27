
class Job
attr_accessor :parent, :path

def initialize(path, parent)
	@path = path
	@parent = parent
end
end

class DirTraverser
attr_accessor :handler

def initialize(handler)
	@handler = handler
	@jobs = Array.new
end

# Depth traversal but with depth number of fds open
def depthTraversal2(path, parent = nil)
	if File.directory?(path)
		dir = handler.addDirectory(parent, path)

		Dir.foreach(path) { |item|
			child = path +"/"+ item
			if File.directory?(child)
				if item != '.' && item != '..'
					depthTraversal(child, dir)
				end
			else
				handler.addFile(dir, item)
			end
		}
	end
end

# Depth traversal but with only one fd open at a time
def depthTraversal(path, parent = nil)
	if File.directory?(path)
		children = Array.new
		dir = handler.addDirectory(parent, path)

		Dir.foreach(path) { |item|
			child = path +"/"+ item
			if File.directory?(child)
				if item != '.' && item != '..'
					children.push child
				end
			else
				handler.addFile(dir, child)
			end
		}

		children.each { |item| breadthTraversal(item, dir) }
	end
end

# scans all nodes on one level first
def breadthTraversal(path, parent = nil)
	@jobs.push Job.new(path, parent)

	while not @jobs.empty?
		btraverse(@jobs.pop)
	end
end

def btraverse(job)
	if File.directory?(job.path)
			dir = handler.addDirectory(job.parent, job.path)

        begin
			Dir.foreach(job.path) { |item|
				if item != '.' && item != '..'
					@jobs.unshift(Job.new(job.path() +"/"+ item, dir))
				end
			}
        rescue => ex
            handler.exception(ex)
        end
	else 
		handler.addFile(job.parent, job.path)
	end
end

end

if __FILE__ == $0 then

class Printer
def initialize(path)
	@path = path
	@trav = DirTraverser.new(self)
end

def printd
	@trav.depthTraversal(@path)
end

def printd2
	@trav.depthTraversal2(@path)
end

def printb
	@trav.breadthTraversal(@path)
end

def addDirectory(parent, path)
	if parent == nil
		@root = path
	end

	print "d"
end

def addFile(parent, path)
	print "f"
end

def exception(ex)
    print "\nGot exception: "+ ex.to_s() +"\n"
end

end

p = Printer.new(ENV['HOME'])

p.printd2
puts

end
