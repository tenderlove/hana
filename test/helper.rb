require 'minitest/autorun'
require 'hana'
require 'json'

module Hana
  class TestCase < Minitest::Test
    TESTDIR = File.dirname File.expand_path __FILE__

    def self.read_test_json_file file
      Module.new {
        tests = JSON.load File.read file
        tests.each_with_index do |test, i|
          next unless test['doc']

          define_method("test_#{test['comment'] || i }") do
            skip "disabled" if test['disabled']

            doc   = test['doc']
            patch = test['patch']

            patch = Hana::Patch.new patch

            if test['error']
              assert_raises(ex(test['error'])) do
                patch.apply doc
              end
            else
              assert_equal(test['expected'] || doc, patch.apply(doc))
            end
          end
        end
      }
    end

    private

    def ex msg
      case msg
      when /Out of bounds/i then Hana::Patch::OutOfBoundsException
      when /Object operation on array/ then
        Hana::Patch::ObjectOperationOnArrayException
      when /test op shouldn't get array element/ then
        Hana::Patch::IndexException
      else
        Hana::Patch::FailedTestException
      end
    end
  end
end
