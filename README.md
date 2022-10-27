# Buffr
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'buffr'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install buffr

## Usage

1. Inherit from the \*Effect classes
2. Add `include BuffrMixin` to your object of choice
3. Now you can instantiate your effects and apply them using `YourObject.apply_to(effect)`
4. You can also cleanse effects from the object using `YourObject.dispel(dispel_group)`

### Extra
You can override the `max_duration` method/property of your effect to change it's duration
You can override the `on_*` callbacks of your effect to change it's behaviour.

Dispel Groups (`@@dispel_groups`) - determine which effects will be displled by a particular dispel.

## Development

There are no dependencies. To run the tests run `ruby test/test_buffr.rb`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/manonox/buffr.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
