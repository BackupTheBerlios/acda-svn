
class AlignPrinter
attr_accessor :width

def initialize(max = 30)
    @directOutput = true
    @width      = []
    @captions   = []
    @lines      = []
    @max        = max
end

def setCaptions(captions)
    @captions = captions
    i = 0
    captions.each { |caption|
        @width[i] = caption.size
        i += 1
    }
end

def addLine(values)
    unless values.size == @captions.size
        raise ArgumentError, "You must specify as many columns as captions."
    end
    @lines.push values
    i = 0
    values.each { |value|
        @width[i] = value.to_s.size if (value.to_s.size() > @width[i])
        i += 1
    }
end

def printLine(line)
    i = 0
    line.each { |entry|
        print entry.to_s.ljust(@width[i]), ' '
        i += 1
    }
    puts
end

def flush()
    printLine(@captions)
    puts "-" * 60
    @lines.each { |line| printLine(line) }
end
end
