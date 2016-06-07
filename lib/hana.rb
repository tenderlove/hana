require 'hana/railtie' if defined?(Rails)

module Hana
  VERSION = '1.3.2'

  class Pointer
    include Enumerable

    def initialize path
      @path = Pointer.parse path
    end

    def each(&block); @path.each(&block); end

    def eval object
      Pointer.eval @path, object
    end

    ESC = {'^/' => '/', '^^' => '^', '~0' => '~', '~1' => '/'} # :nodoc:

    def self.eval list, object
      list.inject(object) { |o, part|
        return nil unless o

        if Array === o
          raise Patch::IndexError unless part =~ /\A\d+\Z/
          part = part.to_i
        end
        o[part]
      }
    end

    def self.parse path
      return [''] if path == '/'

      parts = path.sub(/^\//, '').split(/(?<!\^)\//).each { |part|
        part.gsub!(/\^[\/^]|~[01]/) { |m| ESC[m] }
      }

      parts.push("") if path[-1] == '/'
      parts
    end
  end

  class Patch
    class Exception < StandardError
    end

    class FailedTestException < Exception
      attr_accessor :path, :value

      def initialize path, value
        super "expected #{value} at #{path}"
        @path  = path
        @value = value
      end
    end

    class OutOfBoundsException < Exception
    end

    class ObjectOperationOnArrayException < Exception
    end

    class IndexError < Exception
    end

    class MissingTargetException < Exception
    end

    def initialize is
      @is = is
    end

    VALID = Hash[%w{ add move test replace remove copy }.map { |x| [x,x]}] # :nodoc:

    def apply doc
      @is.inject(doc) { |d, ins|
        send VALID.fetch(ins[OP].strip) { |k|
          raise Exception, "bad method `#{k}`"
        }, ins, d
      }
    end

    private

    PATH  = 'path' # :nodoc:
    FROM  = 'from' # :nodoc:
    VALUE = 'value' # :nodoc:
    OP    = 'op' # :nodoc:

    def add ins, doc
      list = Pointer.parse ins[PATH]
      key  = list.pop
      dest = Pointer.eval list, doc
      obj  = ins.fetch VALUE

      raise(MissingTargetException, ins[PATH]) unless dest

      if key
        add_op dest, key, obj
      else
        dest.replace obj
      end
      doc
    end

    def move ins, doc
      from     = Pointer.parse ins.fetch FROM
      to       = Pointer.parse ins[PATH]
      from_key = from.pop
      key      = to.pop
      src      = Pointer.eval from, doc
      dest     = Pointer.eval to, doc

      obj = rm_op src, from_key
      add_op dest, key, obj
      doc
    end

    def copy ins, doc
      from     = Pointer.parse ins.fetch FROM
      to       = Pointer.parse ins[PATH]
      from_key = from.pop
      key      = to.pop
      src      = Pointer.eval from, doc
      dest     = Pointer.eval to, doc

      if Array === src
        raise Patch::IndexError unless from_key =~ /\A\d+\Z/
        obj = src.fetch from_key.to_i
      else
        obj = src.fetch from_key
      end

      add_op dest, key, obj
      doc
    end

    def test ins, doc
      expected = Pointer.new(ins[PATH]).eval doc

      unless expected == ins.fetch(VALUE)
        raise FailedTestException.new(ins[VALUE], ins[PATH])
      end
      doc
    end

    def replace ins, doc
      list = Pointer.parse ins[PATH]
      key  = list.pop
      obj  = Pointer.eval list, doc

      return ins.fetch VALUE unless key

      if Array === obj
        raise Patch::IndexError unless key =~ /\A\d+\Z/
        obj[key.to_i] = ins.fetch VALUE
      else
        obj[key] = ins.fetch VALUE
      end
      doc
    end

    def remove ins, doc
      list = Pointer.parse ins[PATH]
      key  = list.pop
      obj  = Pointer.eval list, doc
      rm_op obj, key
      doc
    end

    def check_index obj, key
      return -1 if key == '-'

      raise ObjectOperationOnArrayException unless key =~ /\A-?\d+\Z/
      idx = key.to_i
      raise OutOfBoundsException if idx > obj.length || idx < 0
      idx
    end

    def add_op dest, key, obj
      if Array === dest
        dest.insert check_index(dest, key), obj
      else
        dest[key] = obj
      end
    end

    def rm_op obj, key
      if Array === obj
        raise Patch::IndexError unless key =~ /\A\d+\Z/
        obj.delete_at key.to_i
      else
        obj.delete key
      end
    end
  end
end
