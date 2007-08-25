
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
	attr_reader :name, :fields, :sorts, :types

	def self.ASCENDING
		StableSort.ASCENDING
	end

	def self.DESCENDING
		StableSort.DESCENDING
	end

	def initialize(name, types)
		@name  = name
        @types = types
        unless @types.size > 0
            raise ArgumentError, "No types specified."
        end

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

	def push_field(name, display)
		@fields.push([name, display])
	end

	def add_field(pos, name, display)
		@fields[pos, 0] = [name, display]
	end

	def del_field(pos)
		@fields.delete_at(pos)
	end

	def move_field(pos, rel)
		@fields[pos + rel, 0] = @fields.delete_at(pos)
	end

	def push_sort(name, type)
        raise ArgumentError, "name must not be nil" unless name
		@sorts.push(StableSort.new(name, type))
	end

	def add_sort(pos, name, type)
        raise ArgumentError, "name must not be nil" unless name
		@sorts[pos, 0] = StableSort.new(name, type)
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
                begin
                    disc_field << disc.get_value(field[0])
                rescue NoSuchField => ex
                    unless @types[field[0]]
                        puts "View [#{name}]: unkown field '#{field[0]}' found."
                        disc_field << "-"
                    else
                        disc_field << @types[field[0]].default
                    end
                end
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
