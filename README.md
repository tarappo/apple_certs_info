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

## Requirements

macOS only. This gem shells out to `security`, `openssl` and `/usr/libexec/PlistBuddy`.

## Usage

### Expiring soon

Information with an expiration date of 10 days or less will return.

 - Provisioning Profiles

```ruby
AppleCertsInfo.provisioning_profile_list_limit_days_for(days: 10)
```

 - Certificate files（Development / Distribution）

```ruby
# iPhone Developer / Apple Development
AppleCertsInfo.certificate_development_list_limit_days_for(days: 10)

# iPhone / Apple Distribution
AppleCertsInfo.certificate_distribution_list_limit_days_for(days: 10)
```

### All entries

Without filtering by the remaining days.

```ruby
AppleCertsInfo.provisioning_profile_list
AppleCertsInfo.certificate_development_list
AppleCertsInfo.certificate_distribution_list
```

`provisioning_profile_list` reads `~/Library/MobileDevice/Provisioning Profiles/` by default,
and another directory can be given with the `dir:` keyword.

### Return value

Each method returns an Array of Hash.

 - Certificates

| key | description |
| --- | --- |
| `:expire_datetime` | expiration date (`Time`) |
| `:limit_days` | days left until the expiration date (`Integer`) |
| `:cname` | CN of the certificate |

 - Provisioning Profiles

| key | description |
| --- | --- |
| `:expire_datetime` | expiration date (`Time`) |
| `:limit_days` | days left until the expiration date (`Integer`) |
| `:app_identifier` | Bundle Identifier |
| `:app_id_name` | App ID Name |
| `:file_path` | path of the `.mobileprovision` file |

### Debug log

```ruby
AppleCertsInfo.set_debug_log(true)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tarappo/apple_certs_info. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/tarappo/apple_certs_info/blob/main/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AppleCertsInfo project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/tarappo/apple_certs_info/blob/main/CODE_OF_CONDUCT.md).
