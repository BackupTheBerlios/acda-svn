
class ACDADate
    attr_accessor :time
    def initialize(time)
        @time = time
    end

    def to_s
        @time.strftime('%x')
    end

    def to_i
        @time.to_i
    end

    def <=>(b)
        @time <=> b.time
    end
end
