#!/usr/bin/ruby

class MyFile
attr_accessor :name, :path, :size, :mod, :children

def initialize(name,path,size,mod)
	@name = name
	@path = path
	@size = size
	@mod = mod
	@children = Array.new
end

end

def traverse(path)
	stat = File.stat(path)
	file = MyFile.new(File.basename(path), path, stat.size, stat.mtime)

	if File.directory?(path)
		Dir.foreach(path) { |item|
			if item != '.' && item != '..'
				i = traverse(path +"/"+ item)
				if (i != nil)
					file.children.push(i)
				end
			end
		}
	end

	return file
	rescue
	ensure
	return file
end

a=traverse("/home")

def fcount(f)
	count = 1
	f.children.each { |f| count += fcount(f) }
	count
end

puts fcount(a)

def fprint(f)
	puts f.path.to_s() +' || '+ f.size.to_s() +' || '+ f.mod.to_s()

	f.children.each { |f| fprint(f) }
end


