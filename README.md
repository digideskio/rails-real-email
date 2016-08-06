# Rails Real Email

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-real-email'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails-real-email

## Usage

    Rails::Real::Email.email_is_real?('email')
  - It will return true or false
  
### Use with Devise
Note: This approach has been used with Devise 1.5.4 under Rails 3.2.12, YMMV.

Email validation in a production apps is challenging because the RFC is complex, and in the real world different email sub-systems differ in their adherence to the RFC spec. It is not uncommon for a "valid" email to be rejected by a system that may validate email addresses with a too-narrow subset of rules.   

The Devise email validator is intentionally relaxed to reduce the likelihood of rejecting a valid email, but, as a result, may permit users to register with an email address that is not deliverable. One specific example is `someone@example.co,`. Whether or not that address is valid according to the RFC, it clearly cannot be delivered. (And since the comma key is next to the "m" key on most keyboards, it's not that hard for a user to type ".co," instead of ".com")

Rails permits custom validators, so it is quite simple to add your own custom email validator, and no change to Devise is necessary (as long as you want Devise's built-in validator to also be applied). You'll get the union of the two validators, eg, an email has to pass both validators. If your custom validator is "more strict" than Devise's validator (as in this example), your app will have the benefit of the stricter validation automatically.


If your goal is to supplement, but not replace, the Devise email validation, the approach is simpler:

Add to your User model:

```ruby
validates :email, :presence => true, :email => true
```

(Update 2015-Mar-24: the :tree method used was private and is no longer available. A limited check/hack would be to ensure the domain contains at least one '.')

```ruby
# app/validators/email_validator.rb
require 'mail'
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)
    begin
      m = Mail::Address.new(value)
      # We must check that value contains a domain, the domain has at least
      # one '.' and that value is an email address      
      r = m.domain!=nil && m.domain.match('\.') && m.address == value

      # Update 2015-Mar-24
      # the :tree method was private and is no longer available.
      # t = m.__send__(:tree)
      # We need to dig into treetop
      # A valid domain must have dot_atom_text elements size > 1
      # user@localhost is excluded
      # treetop must respond to domain
      # We exclude valid email values like <user@localhost.com>
      # Hence we use m.__send__(tree).domain
      # r &&= (t.domain.dot_atom_text.elements.size > 1)
      r = Rails::Real::Email.email_is_real?(m.address) ? true : false
    rescue   
      r = false
    end
    record.errors[attribute] << (options[:message] || "is invalid") unless r
  end
end
```

3. (Be sure to restart your server)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rails-real-email. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

