module Hana
  VERSION = '1.0.0'

  class Pointer
    include Enumerable

    def initialize path
      @path = Pointer.parse path
    end

    def each
      @path.each { |x| yield x }
    end

    def to_a; @path.dup; end

    def eval object
      Pointer.eval @path, object
    end

    def self.eval list, object
      list.inject(object) { |o, part| o[(Array === o ? part.to_i : part)] }
    end

    def self.parse path
      path.sub(/^\//, '').split(/(?<!\^)\//).map { |part|
        part.gsub(/\^([\/^])/, '\1')
      }
    end
  end

  class Patch
    class Exception < StandardError
    end

    def initialize is
      @is = is
    end

    def apply doc
      @is.each_with_object(doc) { |ins, doc|
        send ins.keys.sort.first, ins, doc
      }
    end

    private

    def add ins, doc
      list = Pointer.parse ins['add']
      key  = list.pop
      obj  = Pointer.eval list, doc

      if Array === obj
        obj.insert key.to_i, ins['value']
      else
        obj[key] = ins['value']
      end
    end

    def move ins, doc
      from     = Pointer.parse ins['move']
      to       = Pointer.parse ins['to']
      from_key = from.pop
      to_key   = to.pop

      src  = Pointer.eval(from, doc)

      if Array === src
        obj = src.delete_at from_key.to_i
      else
        obj = src.delete from_key
      end

      dest = Pointer.eval(to, doc)

      if Array === dest
        dest.insert to_key.to_i, obj
      else
        dest[to_key] = obj
      end
    end

    def test ins, doc
      expected = Pointer.new(ins['test']).eval doc
      raise Exception unless expected == ins['value']
    end

    def replace ins, doc
      list = Pointer.parse ins['replace']
      key  = list.pop
      Pointer.eval(list, doc)[key] = ins['value']
    end

    def remove ins, doc
      list = Pointer.parse ins['remove']
      key  = list.pop
      obj  = Pointer.eval list, doc

      if Array === obj
        obj.delete_at key.to_i
      else
        obj.delete key
      end
    end
  end
end
