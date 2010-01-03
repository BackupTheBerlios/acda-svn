
class Separator
end

class AlignPrinter
attr_accessor :width, :vseparator, :value_separator

def initialize(max = 30)
    @directOutput = true
    @width      = []
    @captions   = []
    @lines      = []
    @max        = max
    @vseparator = "---\n"
    @value_separator = ' '
end

def set_captions(captions)
    @captions = captions
    i = 0
    captions.each { |caption|
        @width[i] = caption.size
        i += 1
    }
end

def add_line(values)
    if @captions.size > 0 and values.size != @captions.size
        raise ArgumentError, "You must specify as many columns as captions."
    end
    @lines.push values
    i = 0
    values.each { |value|
        @width[i] = value.to_s.size if not @width[i] or (value.to_s.size() > @width[i])
        i += 1
    }
end

def add_separator()
   @lines.push Separator.new
end

def print_line(line)
    if line.is_a? Separator
       print @vseparator
       return
    end

    i = 0
    line.each { |entry|
        print entry.to_s.ljust(@width[i]), @value_separator
        i += 1
    }
    puts
end

def flush()
    if @captions.size > 0
       print_line(@captions)
       puts "-" * output_width()
    end

    @lines.each { |line| print_line(line) }
end

def output_width()
  return @width.inject { |sum,width| sum + width + @value_separator.size }
end

end
