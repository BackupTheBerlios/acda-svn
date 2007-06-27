
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

	def clearValues
		@values.clear
	end
end
