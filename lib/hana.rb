module Hana
  VERSION = '1.0.0'

  class Pointer
    include Enumerable

    def initialize path
      @path = parse path
    end

    def each
      @path.each { |x| yield x }
    end

    def eval object
      inject(object) { |o, part| o[(Array === o ? part.to_i : part)] }
    end

    private

    def parse path
      path.sub(/^\//, '').split(/(?<!\^)\//).map { |part|
        part.gsub(/\^([\/^])/, '\1')
      }
    end
  end
end
