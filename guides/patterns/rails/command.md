# Command pattern

The command pattern is a design pattern in which an object is used to encapsulate all information needed to perform an action.
It helps on keeping the Rails controllers and models thin, moving related logic to their own.

## Solution overview

We have chosen to use [SimpleCommand](https://github.com/nebulab/simple_command) to implement the Command pattern. SimpleCommand provides a standard way of defining commands and getting its result. Its a very lightweight gem (~ 100 LOC) which adds no external dependencies but provides a solid basis to create commands from.

## Usage: The command class

Commands are scoped into a module referencing the entity they are working with. There are situations where the command might
not refer to a single entity but to a composition of different entities or an abstraction.
The name of the module doesn't need to match the name of a Rails model.

#### `app/commands/users/update.rb`

```ruby
module Users
  class Update # (1)

    prepend SimpleCommand #(2)

    def initialize(user, params) # (4)
      @user = user
      @params = params
    end

    def call # (5)
      if @user.update(@params)
        some_private_method
        @user
      else
        some_more_stuff
        errors.add_multiple_errors(@user.errors)
        nil
      end
    end

  end
end


```

- (1) The command name should be a verb as it represents an action.
- (2) We use the [SimpleCommand](https://github.com/nebulab/simple_command) gem to have basic functionality like asking if the execution was successful or not, and retrieving errors.
- (3) All the parameters needed for the command to work must be passed to the initializer. The initializer should not contain any logic. It's only meant to be used for instance variable assignments.
- (4) `call` is the only public method of the command. It doesn't accept parameters. The idea behind a command is a chainable class used to perform a single operation that is complex enough to require private methods or to depend on other commands or classes. The call method should return the resulting value of the action. Then we can ask the command for the success status or errors

## Usage: Calling the command

A command can be called from anywhere, being a controller, a background job, rake tasks or other commands the most common places.
After calling a command, the `then` keyword with the result object as a block param is used as a syntactic sugar to
encapsulate the possible actions derived from the execution of the command.

#### `app/controllers/users_controller.rb`

```ruby
class UsersController < ApplicationController

  def update
    authorize User

    Users::Update.call(user, user_params).then do |command| # (1)
      if command.success?
        redirect_to dashboard_path # (2)
      else
        @user = command.result
        flash.now[:error] = t('.error')
        render :new
      end
    end
  end

end

```

- (1) Using the `then` keyword is only available since Ruby 2.6. For Ruby 2.5 `yield_self` can be used. Previous Ruby versions need to use `tap`. Take into account that tap is different from `yield_self` or `then`.
- (2) The only logic expected to be present inside the `then` block are the calls to controller methods that are no available inside the command.

## FAQ

### Should the command pattern be used for any code logic present at controllers?

Commands are only intended to be used if there are side effects in the code or there are multiple operations that need to be performed as one.
For simple ActiveRecord operations there is no need to create a Command.

As a rule of thumb, use a command if you are defining multiple private methods related to a common functionality inside a class that has other responsibilities besides the one you are implementing.

### I need to create a module for just one command?

Yes. It's important to start organizing commands as soon as posible to avoid having many unrelated classes in the commands folder.

### Should I create a base class for commands to reuse functionality?

The beauty of this solution is that it's very flexible. You can create the Result object that you want and it's very easy to understand
for other developers not used to the pattern.

### Testing guidelines

One of the advantages of using commands is being able to test business logic without having to write controller or system tests.
In order to maintain commands easy to test they shouldn't have dependencies from Rails controllers or views. Also, it's also recommended injecting dependencies that the command needs in the initializer to better mock them.
