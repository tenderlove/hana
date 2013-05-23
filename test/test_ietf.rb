require 'helper'

module Hana
  class TestIETF < TestCase
    filename = File.join TESTDIR, 'json-patch-tests', 'tests.json'
    include read_test_json_file filename
  end
end
