
require 'OptionalTypes.rb'
require 'OptionalValue.rb'

class Disc
	attr_accessor :number, :title,
				  :addingDate, :modifiedDate, :scanned,
				  :bytesSize, :numberOfFiles, :values
	alias id number

	def initialize(number, title = '', scanned = false, bytesSize = 0,
				   numberOfFiles = 0, addingDate = nil, modifiedDate = nil)
		@number		   = number
		@title		   = (title) ? title : ''
		@scanned       = scanned
		@bytesSize	   = bytesSize
		@numberOfFiles = numberOfFiles
		@scanned	   = scanned
		@addingDate    = addingDate
		@modifiedDate  = modifiedDate

		@addingDate   = Time.now if not @addingDate
		@modifiedDate = Time.now if not @modifiedDate

		@values = []
	end

	def modified
		@modifiedDate = Time.now
	end

	def addValue(type, value)
		@values.push OptionalValue.new(type, value)
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
                @values.each { |optval|
                    return optval.display_value if optval.type.id == id
                    # TODO correct?
                }
                raise ArgumentError, "No value with id '#{id}' found."
        end
    end

	def clearValues
		@values.clear
	end
end
