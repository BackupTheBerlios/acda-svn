
class View
	attr_reader :id, :fields, :sorts

	@@ASCENDING  = 0
	@@DESCENDING = 1

	def View.ASCENDING
		@@ASCENDING
	end

	def View.DESCENDING
		@@DESCENDING
	end

	def initialize(id)
		@id = id

		@fields = Array.new
		@sorts = Array.new
	end

	def num_of_fields()
		@fields.length / 2
	end

	def field_names()
		ret = Array.new
		i = 0
		while i < @fields.length do
			ret.push(@fields[i])
			i += 2
		end
	end

	def field_displays()
		ret = Array.new
		i = 0
		while i < @fields.length do
			if @fields[i + 1].nil?
				ret.push(@fields[i])
			else
				ret.push(@fields[i + 1])
			end
			i += 2
		end
	end

	def push_field(id, display)
		@fields.push([id, display])
	end

	def add_field(pos, id, display)
		@fields[pos, 0] = [id, display]
	end

	def del_field(pos)
		@fields.delete_at(pos)
	end

	def move_field(pos, rel)
		@fields[pos + rel, 0] = @fields.delete_at(pos)
	end

	def push_sort(id, type = @@ASCENDING)
		@sorts.push([id, type])
	end

	def add_sort(pos, id, type = @@ASCENDING)
		@sorts[pos, 0] = [id, type]
	end

	def del_sort(pos)
		@sorts.delete_at(pos)
	end

	def move_sort(pos, rel)
		@sorts[pos + rel, 0] = @sorts.delete_at(pos)
	end
end
