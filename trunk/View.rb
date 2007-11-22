
class StableSort
	@@ASCENDING  = 0
	@@DESCENDING = 1

	def self.ASCENDING
		@@ASCENDING
	end

	def self.DESCENDING
		@@DESCENDING
	end

    attr_accessor :by, :type

    def initialize(by, type = @@ASCENDING)
        @by = by
        @type = type

        raise ArgumentError, "Sort by must be a Type" unless by.is_a? Type

        if type != @@ASCENDING and type != @@DESCENDING
            raise ArgumentError, "Sort type must be either ascending "+
                                 "or descending.\n"
        end
    end

    def do(elements)
        elements.sort! { |a,b|
            val_a = a.get_value(@by.name())
            val_a = @by.default unless val_a

            val_b = b.get_value(@by.name())
            val_b = @by.default unless val_b

            if (@type == @@ASCENDING)
                val_a <=> val_b
            else
                val_b <=> val_a
            end
        }
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

	def push_sort(by, type)
        raise ArgumentError, "name must not be nil" unless name
        raise ArgumentError, "Sort by must be a Type" unless by.is_a? Type
		@sorts.push(StableSort.new(by, type))
	end

	def add_sort(pos, by, type)
        raise ArgumentError, "name must not be nil" unless name
        raise ArgumentError, "Sort by must be a Type" unless by.is_a? OptionalType
		@sorts[pos, 0] = StableSort.new(by, type)
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
                    puts "#{field[0]} -> #{disc.get_value(field[0]).inspect} -> #{disc.get_value(field[0]).display_value}"
                    disc_field << disc.get_value(field[0]).display_value
                rescue NoSuchField => ex
                    unless @types[field[0]]
                        puts "View [#{name}]: unkown field '#{field[0]}' found."
                        disc_field << "-"
                    else
                        disc_field << @types[field[0]].default.display_value
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
