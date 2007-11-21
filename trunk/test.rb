
class Vater
    def do
        puts self.class
    end
end

class Sohn < Vater
end

Vater.new.do
Sohn.new.do
