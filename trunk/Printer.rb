
class Printer
attr_accessor :width

def initialize()
    @directOutput = true
    @width = []
end

def setCaptions(captions)
    puts captions.join(' ')
end

def addLine(values)
    if width.size == values.size
        i = 0
        values.each { |value|
            print value.to_s.ljust(@width[i]), " "
            i += 1
        }
        puts
    else
        puts values.join(' ')
    end
end

def flush()
end
end
