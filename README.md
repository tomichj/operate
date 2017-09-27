# Operate

Operate is a gem to help create [service objects].

Use Operate to __remove all business logic from your controller and model__, subsuming it in an Operate-based 
class that represents your processes. Examples might be: a user addition, a post addition, or adding  a comment.  

Service objects can out factor behavior that would bloat models or controllers, and is a useful step to patterns
like Strategy and Command.

Operate is in the very earliest stages of development. Additional features will be added. The core API 
exposed via `Operate::Command` is solid and no changes are in the words.


## Dependencies

Operate requires:
* `ActiveRecord` 4.2 or greater
* `ActiveSupport` 4.2 or greater

It's not required, but a form object library like [Reform] is recommended. Reform is used in the examples below.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'operate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install operate


## Usage

Just `include Operate::Command` in your class. Operate's api provides:

Methods used in your service class:
* `self#call(*args, &block)` will initialize your service class with *args and invoke #call
* `#broadcast(:event, *args)` that will broadcast an event to a subscriber
* `#transaction(&block)` that wraps a block inside a transaction

Methods used by clients of your service class:
* `#on(*events, &block)` that subscribe to an event or events, and provide a block to handle that event


An example service:

```ruby
class UserAddition
  include Operate::Command
  
  def initialize(form, params)
    @form = form
    @params = params
  end
  
  def call
    return broadcast(:invalid) unless @form.validate(@params)
    
    transaction do
      create_user
      audit_trail
      welcome_user
    end
    
    broadcast(:ok)
  end
  
  def create_user
    # ...
  end
  
  def audit_trail
    # ...
  end
  
  def welcome_user
    # ...
  end
end
```

And your controller:

```ruby
class UserController < ApplicationController
  def create
    @form = UserForm.new(params) # a simple Reform form object
    UserAddition.call(@form) do
      on(:ok)      { redirect_to dashboard_path }
      on(:invalid) { render :new }
    end
  end
end
```


## Credit

The core of Operate is based on [rectify] and [wisper], and would not exist without these fine projects.
Both rectify and wisper are excellent gems, they just provide more functionality than I require, and with
some philosophical differences in execution (rectify requires you extend their base class, operate provides mixins).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tomichj/operate. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are 
expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[service objects]: https://gist.github.com/blaix/5764401
[Reform]: http://trailblazer.to/gems/reform/index.html
[rectify]: https://github.com/andypike/rectify
[wisper]: https://github.com/krisleech/wisper
