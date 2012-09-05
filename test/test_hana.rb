require 'minitest/autorun'
require 'hana'

class TestHana < MiniTest::Unit::TestCase
  def test_split_many
    pointer = Hana::Pointer.new '/foo/bar/baz'
    assert_equal %w{ foo bar baz }, pointer.to_a
  end

  def test_root
    pointer = Hana::Pointer.new '/'
    assert_equal [], pointer.to_a
  end

  def test_escape
    pointer = Hana::Pointer.new '/f^/oo/bar'
    assert_equal ['f/oo', 'bar'], pointer.to_a

    pointer = Hana::Pointer.new '/f^^oo/bar'
    assert_equal ['f^oo', 'bar'], pointer.to_a
  end

  def test_eval_hash
    pointer = Hana::Pointer.new '/foo'
    assert_equal 'bar', pointer.eval('foo' => 'bar')

    pointer = Hana::Pointer.new '/foo/bar'
    assert_equal 'baz', pointer.eval('foo' => { 'bar' => 'baz' })
  end

  def test_eval_array
    pointer = Hana::Pointer.new '/foo/1'
    assert_equal 'baz', pointer.eval('foo' => ['bar', 'baz'])

    pointer = Hana::Pointer.new '/foo/0/bar'
    assert_equal 'omg', pointer.eval('foo' => [{'bar' => 'omg'}, 'baz'])
  end

  def test_eval_number_as_key
    pointer = Hana::Pointer.new '/foo/1'
    assert_equal 'baz', pointer.eval('foo' => { '1' => 'baz' })
  end
end
