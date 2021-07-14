# Query object pattern

This pattern is used to encapsulate complex database queries in an object.

It helps to maintain Rails code simple by separating algorithms from how the data needs to be gathered.

## Solution overview

All query objects are POROs placed in the `/app/queries/` folder.

## Usage: Query object

The actual object that encapsulates all the logic.

### `app/queries/search_users.rb`

```ruby
# frozen_string_literal: true

class SearchUsers # (1)

  def initialize(scope = User.all) # (2)
    @scope = scope
  end

  def call(filters: {}) # (3)
    filter_by_email(filters[:email]) if filters[:email]
    filter_by_language(filters[:language]) if filters[:language]

    @scope.order(created_at: :desc)
  end

  private

  def filter_by_email(email)
    @scope = @scope.where('email ILIKE %?%', email)
  end

  def filter_by_language(language)
    @scope = @scope.joins(:profile).where(profile: { language: language })
  end

end
```

- (1) The name for that object explains its concrete use case. There's no need to add `Query` as a prefix.
- (2) The initializer takes a scope to start from. This allows to compose it with other query objects and/or regular ActiveRecord methods.
- (3) The class has a single call method taking the additional parameters needed to perform the query, if any. The method calls a number of private methods to incrementally build the query in small steps. In the end, it adds an order clause to make sure the query always returns the same results having the same data in the DB.

## Usage: Querying data

Can be used from all parts of the code that usually need to interact with the DB, like controllers, services or the model itself.

```ruby
users = SearchUsers.new.call(language: :en, email: "baker221b@example.com")
```

## Usage: From a controller

### `app/controllers/users_controller.rb`

```ruby
# frozen_string_literal: true

class UsersController < ApplicationController

  def index
    @users = SearchUsers.new(User.active).call(search_params) # (1)
  end

  private

  def search_params
    params.require(:search).permit(:email, :language)
  end

end
```

- (1) `call` always receives a previously filtered list of params

## FAQ

### Are ActiveRecord-only implementations for searching (class methods, scopes,...) discouraged?

No. Scopes usually contain easy queries, semantically useful across the entire project. Query objects encapsulate complex queries that may combine multiple tables, specific performance tweaks; or their behaviour is very specific to concrete use cases and are complex enough to need to be encapsulated individually.
