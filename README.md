# AppleCertsInfo

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'apple_certs_info'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install apple_certs_info

## Usage

Information with an expiration date of 10 days or less will return.

 - Provisioning Profiles

```
AppleCertsInfo.provisioning_profile_list_limit_days_for(days: 10)
```

 - Certificatefiles（Development / Distribution）


```
# iPhone Developer / Apple Development
AppleCertsInfo.certificate_development_list_limit_days_for(days: 10)

# iPhone / Apple Distribution
AppleCertsInfo.certificate_distribution_list_limit_days_for(days: 10)
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tarappo/apple_certs_info. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/tarappo/apple_certs_info/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AppleCertsInfo project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/tarappo/apple_certs_info/blob/master/CODE_OF_CONDUCT.md).
