
require 'OptionalTypes.rb'
require 'OptionalValue.rb'
require 'ACDADate.rb'

class Disc
	attr_accessor :number, :title,
				  :scanned, :bytesSize,
                  :numberOfFiles, :values
    attr_reader :addingDate, :modifiedDate
	alias id number

	def initialize(number, title = '', scanned = false, bytesSize = 0,
				   numberOfFiles = 0, addingDate = nil, modifiedDate = nil)
		@number		   = number
		@title		   = (title) ? title : ''
		@scanned       = scanned
		@bytesSize	   = bytesSize
		@numberOfFiles = numberOfFiles
		@scanned	   = scanned
        if @addingDate
		    @addingDate = addingDate
        else
		    @addingDate = ACDADate.new(Time.now)
        end

		@modifiedDate = modifiedDate
		@modifiedDate = ACDADate.new(Time.now) if not @modifiedDate

		@values = Hash.new
	end

	def modified
		@modifiedDate = Time.now
	end

	def addValue(value)
        if value.class == "Array" or value == nil
            raise RuntimeError, "Invalid type added."
        end
		@values[value.get_type.get_id] = value
	end

    def get_value(id)
        case id
            when "Number"
                return @number
            when "Title"
                return @title
            when "AddingDate"
                return @addingDate
            when "ModifiedDate"
                return @modifiedDate
            when "Scanned"
                return @scanned
            when "BytesSize"
                return @bytesSize
            when "NumberOfFiles"
                return @numberOfFiles
            else
                unless @values[id]
                    raise NoSuchField, "No field with id '#{id}' found." 
                end
                return @values[id]
        end
    end

	def clearValues
		@values.clear
	end

    def addingDate(date)
        raise ArgumentError, "Invalid type, ACDADate expected" unless
            date.is_a? ACDADate
        @addingDate = date
    end
    alias addingDate= addingDate 

    def modifiedDate(date)
        raise ArgumentError, "Invalid type, ACDADate expected" unless
            date.is_a? ACDADate
        @modified = date
    end
    alias modifiedDate= modifiedDate
end
