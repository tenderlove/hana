# hana

* http://github.com/tenderlove/hana

## DESCRIPTION:

Implementation of [JSON Patch][1] and [JSON Pointer][2] RFC.

## FEATURES/PROBLEMS:

Implements specs of the [JSON Patch][1] and [JSON pointer][2] RFCs:

This works against Ruby objects, so you should load the JSON to Ruby,
process it, then emit as JSON again.

## SYNOPSIS:

```ruby
patch = Hana::Patch.new [
  { 'op' => 'add', 'path' => '/baz', 'value' => 'qux' }
]

patch.apply('foo' => 'bar') # => {'baz' => 'qux', 'foo' => 'bar'}
```

## REQUIREMENTS:

* Ruby

## INSTALL:

    $ gem install hana

## DEVELOPMENT:

hana runs tests from [json-patch/json-patch-tests](https://github.com/json-patch/json-patch-tests). Fetch the git submodule by running:

```bash
git submodule init
git submodule update
```

Install dependencies with:

```bash
bundle install
```

Then run the tests with:

```bash
rake test
```

[1]: https://datatracker.ietf.org/doc/rfc6902/
[2]: http://tools.ietf.org/html/rfc6901

