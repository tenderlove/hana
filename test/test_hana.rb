require 'helper'

class TestHana < Hana::TestCase
  def test_no_eval
    patch = Hana::Patch.new [
      { 'op' => 'eval', 'value' => '1' }
    ]
    assert_raises(Hana::Patch::Exception) do
      patch.apply('foo' => 'bar')
    end
  end

  def test_mutate_to_a_does_not_impact_original
    pointer = Hana::Pointer.new '/foo/bar/baz'
    x = pointer.to_a
    x << "omg"
    assert_equal %w{ foo bar baz omg }, x
    assert_equal %w{ foo bar baz }, pointer.to_a
  end

  def test_split_many
    pointer = Hana::Pointer.new '/foo/bar/baz'
    assert_equal %w{ foo bar baz }, pointer.to_a
  end

  def test_root
    pointer = Hana::Pointer.new '/'
    assert_equal [''], pointer.to_a
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
