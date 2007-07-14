
class StableSort
	@@ASCENDING  = 0
	@@DESCENDING = 1

	def self.ASCENDING
		@@ASCENDING
	end

	def self.DESCENDING
		@@DESCENDING
	end

    attr_accessor :id, :type

    def initialize(name, type = @@ASCENDING)
        @id   = name
        @type = type

        if type != @@ASCENDING and type != @@DESCENDING
            raise ArgumentError, "Sort type must be either ascending "+
                                 "or descending.\n"
        end
    end

    def do(elements)
        if type == @@ASCENDING
            elements.sort! { |a,b| a.get_value(@id) <=> b.get_value(@id) }
        
        else
            elements.sort! { |b,a| a.get_value(@id) <=> b.get_value(@id) }
        end
    end
end

class View
	attr_reader :id, :fields, :sorts

	def self.ASCENDING
		StableSort.ASCENDING
	end

	def self.DESCENDING
		StableSort.DESCENDING
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
        @fields.each { |field|
			ret.push(field[0])
        }

        return ret
	end

	def field_displays()
		ret = Array.new
        @fields.each { |field|
			if field[1].nil?
				ret.push(field[0])
			else
				ret.push(field[1])
			end
        }

        return ret
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

	def push_sort(id, type)
        raise ArgumentError, "Id must not be nil" unless id
		@sorts.push(StableSort.new(id, type))
	end

	def add_sort(pos, id, type)
        raise ArgumentError, "Id must not be nil" unless id
		@sorts[pos, 0] = StableSort.new(id, type)
	end

	def del_sort(pos)
		@sorts.delete_at(pos)
	end

	def move_sort(pos, rel)
		@sorts[pos + rel, 0] = @sorts.delete_at(pos)
	end

    def process(discs)
        sort(discs)
        discs.each { |disc|
            disc_field = Array.new
            @fields.each { |field|
                disc_field << disc.get_value(field[0])
            }
            yield disc_field
        }
    end

    def sort(discs)
        @sorts.reverse_each { |sort|
            sort.do(discs)
        }
    end
end
