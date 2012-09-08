require 'helper'

module Hana
  class TestPatch < TestCase
    def test_no_eval
      patch = Hana::Patch.new [
        { 'eval' => '1' }
      ]
      assert_raises(Hana::Patch::Exception) do
        patch.apply('foo' => 'bar')
      end
    end

    def test_add_member
      patch = Hana::Patch.new [
        { 'add' => '/baz', 'value' => 'qux' }
      ]

      result = patch.apply('foo' => 'bar')
      assert_equal({'baz' => 'qux', 'foo' => 'bar'}, result)
    end

    def test_add_array
      patch = Hana::Patch.new [
        { "add" => "/foo/1", "value" => "qux" }
      ]

      result = patch.apply({ "foo" => [ "bar", "baz" ] })

      assert_equal({ "foo" => [ "bar", "qux", "baz" ] }, result)
    end

    def test_remove_object_member
      patch = Hana::Patch.new [ { "remove" => "/baz" } ]

      result = patch.apply({ 'baz' => 'qux', 'foo' => 'bar' })

      assert_equal({ "foo" => 'bar' }, result)
    end

    def test_remove_array_element
      patch = Hana::Patch.new [ { "remove" => "/foo/1" } ]
      result = patch.apply({ "foo" => [ "bar", "qux", "baz" ] })
      assert_equal({ "foo" => [ "bar", "baz" ] }, result)
    end

    def test_replace_value
      patch = Hana::Patch.new [ { "replace" => "/baz", "value" => "boo" } ]
      result = patch.apply({ "baz" => "qux", "foo" => "bar" })
      assert_equal({ "baz" => "boo", "foo" => "bar" }, result)
    end

    def test_moving_a_value
      doc = {
        "foo" => {
          "bar"   => "baz",
          "waldo" => "fred"
        },
        "qux" => {
          "corge" => "grault"
        }
      }

      patch = [ { "move" => "/foo/waldo", 'to' => "/qux/thud" } ]

      expected = {
        "foo" =>  {
          "bar" =>  "baz"
        },
        "qux" =>  {
          "corge" =>  "grault",
          "thud" =>  "fred"
        }
      }

      patch = Hana::Patch.new patch
      result = patch.apply doc
      assert_equal expected, result
    end

    def test_move_an_array_element
      # An example target JSON document:
      doc = {
        "foo" => [ "all", "grass", "cows", "eat" ]
      }

      # A JSON Patch document:
      patch = [
        { "move" => "/foo/1", "to" => "/foo/3" }
      ]

      # The resulting JSON document:
      expected = {
        "foo" => [ "all", "cows", "eat", "grass" ]
      }

      patch = Hana::Patch.new patch
      result = patch.apply doc
      assert_equal expected, result
    end

    def test_testing_a_value_success
      # An example target JSON document:
      doc = {
        "baz" => "qux",
        "foo" => [ "a", 2, "c" ]
      }

      # A JSON Patch document that will result in successful evaluation:
      patch = [
          { "test" => "/baz", "value" => "qux" },
          { "test" => "/foo/1", "value" => 2 },
          { "add" => "/bar", "value" => 2 },
      ]

      expected = {
        "baz" => "qux",
        "foo" => [ "a", 2, "c" ],
        'bar' => 2
      }

      patch = Hana::Patch.new patch
      result = patch.apply doc
      assert_equal expected, result
    end

    def test_testing_a_value_error
      # An example target JSON document:
      doc = { "baz" => "qux" }

      # A JSON Patch document that will result in an error condition:
      patch = [
        { "test" => "/baz", "value" => "bar" }
      ]

      patch = Hana::Patch.new patch

      assert_raises(Hana::Patch::Exception) do
        patch.apply doc
      end
    end

    def test_add_nested_member_object
      # An example target JSON document:
      doc = { "foo" => "bar" }
      # A JSON Patch document:
      patch = [
        { "add" => "/child", "value" => { "grandchild" => { } } }
      ]

      # The resulting JSON document:
      expected = {
        "foo" => "bar",
        "child" => { "grandchild" => { } }
      }

      patch = Hana::Patch.new patch
      result = patch.apply doc
      assert_equal expected, result
    end
  end
end
