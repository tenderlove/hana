require 'helper'
require 'json'

module Hana
  class TestIETF < TestCase
    TESTDIR = File.dirname File.expand_path __FILE__
    json    = File.read File.join TESTDIR, 'json-patch-tests', 'tests.json'
    tests = JSON.load json
    tests.each_with_index do |test, i|
      next unless test['doc']

      define_method("test_#{test['comment'] || i }") do
        skip "disabled" if test['disabled']

        doc   = test['doc']
        patch = test['patch']

        skip "copy doesn't make sense" if patch.any? {|ins| ins['op'] == 'copy'}

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

    private

    def ex msg
      case msg
      when /Out of bounds/i then Hana::Patch::OutOfBoundsException
      when /Object operation on array/ then
        Hana::Patch::ObjectOperationOnArrayException
      else
        Hana::Patch::FailedTestException
      end
    end
  end
end
