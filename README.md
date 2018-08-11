# Operate

Operate is a gem to help create [service objects].

[![Gem Version](https://badge.fury.io/rb/operate.svg)](https://badge.fury.io/rb/operate) ![Build status](https://travis-ci.org/tomichj/operate.svg?branch=master) ![Code Climate](https://codeclimate.com/github/tomichj/operate/badges/gpa.svg)

Use Operate to __remove business logic from your controller and model__, subsuming it in Operate-based 
"service" object that represents your processes. Examples might be: a user addition, a post addition, 
or adding a comment.  

Service objects can factor out behavior that would bloat models or controllers, and is a useful step to patterns
like Strategy and Command.

Service objects are not a new concept, and extracting controller bloat to service objects is a common 
refactoring pattern. This [Arkency blog post] describes extracting service objects using SimpleDelegator, a
useful pattern. Operate can assist you with process, further refining it: rather than raising exceptions in your
service object, and rescuing exceptions in your controller, we broadcast and subscribe to events.

Operate is in the very earliest stages of development. Additional features will be added. The current API 
exposed via `Operate::Command`, however, is solid and no breaking changes there are anticipated.


## Dependencies

If ActiveRecord is available, transactions are supported. There is no explicit support for other ORMs.

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
* `#broadcast(:event, *args)` will broadcast an event to a subscriber (see `on` below)
* `#transaction(&block)` wraps a block with an `ActiveRecord::Base.transaction` (only if ActiveRecord is available)

Methods used by clients (normally a controller) of your service class:
* `#on(*events, &block)` that subscribe to an event or events, and provide a block to handle that event


### A basic service

```ruby
# put in app/services, app/commands, or something like that
class UserAddition
  include Operate::Command
  
  def initialize(form, params)
    @form = form
    @params = params
  end
  
  def call
    return broadcast(:invalid) unless @form.validate(@params[:user])
    
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

Note: this example does not use [Strong Parameters] as [Reform] provides an explicit form property layout.


### Passing parameters

You can pass parameters to the handling block by supplying the parameters as arguments to `broadcast`.

```ruby
# Your service
class UserAddition
  include Operate::Command
  def call
    # ...
    broadcast(:ok, user)
  end
end


# Your client (a controller):
 def create
  UserAddition.call(@form) do
    on(:ok) {|user| logger.info "#{user.name} created" }
  end
end
```


## Testing

A straight-forward way to test the events broadcast by an `Operate::Command` implementor:

```ruby
class UserAddition
  include Operate::Command
  # ...
  def call
    return broadcast(:invalid) if form.invalid?
    # ...
    broadcast(:ok) 
  end
end
```

```ruby
describe UserAddition do
  it 'broadcasts ok when creating user' do
    is_ok = false
    UserAddition.call(attributes_for(:new_user)) do
      on(:ok) { is_ok = true }
    end
    expect(is_ok).to eq true
  end
  it 'broadcasts invalid when user validation fails' do
    is_invalid = false
    UserAddition.call(attributes_for(:invalid_user)) do
      on(:invalid) { is_invalid = true }
    end
    expect(is_invalid).to eq true
  end
end
```

## Credit

The core of Operate is based on [rectify] and [wisper], and would not exist without these fine projects.
Both rectify and wisper are excellent gems, they just provide more functionality than I require, and with
some philosophical differences in execution (rectify requires you to extend their base class, operate provides mixins).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tomichj/operate. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are 
expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## Contributors

Many thanks to:

* [k3rni](https://github.com/k3rni) made ActiveRecord dependency optional


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[service objects]: https://gist.github.com/blaix/5764401
[arkency blog post]: http://blog.arkency.com/2015/05/extract-a-service-object-using-simpledelegator/
[Reform]: http://trailblazer.to/gems/reform/index.html
[String Parameters]: https://github.com/rails/strong_parameters
[rectify]: https://github.com/andypike/rectify
[wisper]: https://github.com/krisleech/wisper
