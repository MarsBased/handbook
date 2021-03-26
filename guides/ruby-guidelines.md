# Ruby guidelines

We follow the `Rubocop` official [Rubocop Ruby coding style guide](https://github.com/rubocop/ruby-style-guide) as the primary source of best practices and conventions.

- 1. [Do's and Don'ts](#DosandDonts)
  - 1.1. [Environment Variables](#Environmentvars)
  - 1.2. [Loading in batches](#Batchloading)
  - 1.3. [Avoid Active Record callbacks with side effects](#Modelcallbacks)
  - 1.4. [Avoid raw SQL queries](#Manualqueries)
  - 1.5. [Size instead of count](#SizeCount)
  - 1.6. [Avoid N+1 Queries with includes](#UseIncludes)
  - 1.7. [Avoid Default Scope](#AvoidDefaultScope)
  - 1.8. [Use find_by for instead where().first](#FindByInsteadWhere)
  - 1.9. [Check constraints](#CheckConstraints)
  - 1.10. [Filter sensitive parameters in logs](#FilterSensitiveParameters)
- 2. [General project organization and architecture](#Generalprojectorganizationandarchitecture)
  - 2.1. [Project structure example](#Projectstructureexample)
- 3. [Common Patterns](#CommonPatterns)
  - 3.1. [Devise (Authentication)](#DeviseIntegration)
  - 3.2. [Testing](#Testing)
    - 3.2.1 [Testing best practices](#TestingBestPractices)
      - 3.2.1.1 [Use Let](#UseLet)
      - 3.2.1.2 [Use Factories](#UseFactories)
      - 3.2.1.3 [Describe Methods](#DescribeMethods)
- 4. [Gems](#Gems)

## 1. <a name='DosandDonts'></a>Do's and Don'ts

Add and follow the official [MarsBased Rubocop configuration](https://github.com/MarsBased/marstyle/blob/master/ruby/.rubocop.yml), where most of rules are already defined, highlighting these two:
- Use single quotes when possible.
- Max length of 90 characters

### 1.1. <a name='Environmentvars'></a>Use Dotenv for environment variables

We use the [Dotenv](https://github.com/bkeepers/dotenv) gem for managing the environment variables.

### 1.2. <a name='Batchloading'></a>Loading in batches

Don't iterate unlimited / big queries directly. Use find in batches for loading big queries:

```ruby
# WRONG
Car.all.each do |car|
  car.start_engine!
end

# RIGHT
Car.find_each do |car|
  car.start_engine!
end
```

### 1.3. <a name='Modelcallbacks'></a>Avoid Active Record callbacks with side effects

Avoid using Active Record callbacks unless it's related to data persistence specially avoiding side effects like sending and e-email.

Consider using the [command pattern](https://github.com/MarsBased/handbook/blob/master/guides/patterns/rails/command.md) to send the e-mail from a controller action.

```ruby
# WRONG
after_save :notify_user

def notify_user
  UserMailer.notify(user).deliver
end
```

### 1.4. <a name='Manualqueries'></a>Avoid raw SQL queries

Avoid writing raw SQL queries unless strictly necessary.

When using Active Record we have the full power of it. For example if we have a custom serialization for a column, Active Record will automatically convert the value when writing queries.

```ruby
# WRONG
User.where('active = ?', params[:active])

# RIGHT
User.where(active: params[:active])
```

When writing more complex queries you may use Arel or write the where clause manually. However take into account that if you write it manually you won't have the full power of Active Record, like:
* You will not be able to use alias attributes.
* You will not be able to use custom types (serialization and deserialization).

```ruby
class User < ApplicationRecord
  alias_attribute :created_at, :dtCreationDate
end

# MANUAL
User.where('dtCreationDate < ?', DateTime.current) # Needs to use column name in the database

# AREL
User.where(User.arel_table[:created_at].lt(DateTime.current)) # Can use aliased name
```

### 1.5. <a name='SizeCount'></a>Size instead of count

Use `size` instead of `count` unless you are doing a direct count on a table. Using `count` always triggers a query while using `size` is able to use the cached values of a previous query.

```ruby
# WRONG
Post.published.count

# RIGHT
Post.published.size

# RIGHT
Post.count # Counting directly on the model class
```

### 1.6. <a name='UseIncludes'></a>Avoid N+1 Queries with includes
When you have to access an association, avoid N+1 query problems, you can use `includes` to eager load the associated records:

```ruby
# WRONG
User.all.each do |user|
  user.posts.each do |post|
    p post.title
  end
end

# RIGHT
User.includes(:posts).each do |user|
  user.posts.each do |post|
    p post.title
  end
end
```

You can find some more examples in the [Active Record guide](https://github.com/MarsBased/handbook/blob/master/guides/development/activerecord-guide.md).

### 1.7. <a name='AvoidDefaultScope'></a>Avoid Default Scope
In order to avoid unexpected and hidden behaviour, avoid using default_scope and use named scopes and explicit uses of those scopes:

```ruby
# WRONG
class User < ActiveRecord::Base
  default_scope { where(deleted: false) }
end

# RIGHT
class User < ActiveRecord::Base
  scope :active, -> { where(deleted: false) }
end
```

### 1.8. <a name='FindByInsteadWhere'></a>Use find_by for instead where().first
When retrieving a single record from the database, don’t use `where(...).first`, use `find_by` instead. And similarly when selecting a single item from a collection use `find { ... }` instead of `select { ... }.first`.

```ruby
# WRONG
User.where(active: true).first

# RIGHT
User.find_by(active: true)
```

### 1.9. <a name='CheckConstraints'></a>Check database constraints
Check that constraints are correct and that they match the validations. A typical example is adding a default without a not-null constraint.

### 1.10. <a name='FilterSensitiveParameters'></a>Filter sensitive parameters in logs
When receiving parameters in a controller that contain sensitive information like a password or secret key, add the name of the parameter to the list of filtered parameters. Note that `:password` is already filtered by default.

```ruby
Rails.application.config.filter_parameters += [:api_key, :secret]
```

## 2. <a name='Generalprojectorganizationandarchitecture'></a>General project organization and architecture

Follow the standard generated directory structure at project initialization with `rails new project_name` as described in [Ruby On Rails Guide](https://guides.rubyonrails.org/getting_started.html).

Additionally:
- Services under the `/app/services` directory.
- Commands under the `/app/commands` directory.
- Presenters under the `/app/presenters` directory.
- Query objects under the `/app/queries` directory.
- Form objects under the `/app/form_objects` directory.

### 2.1. <a name='Projectstructureexample'></a>Project structure example
```
app/
 |- assets/
 |- channels/
 |- controllers/
 |- helpers/
 |- jobs/
 |- mailers/
 |- models/
 |- form_objects/
 |- queries/
 |- presenters/
 |- services/
 |- commands/
 |- views/
bin/
config/
 |-environments/
 |-initializers/
 |-locales/
db/
 |- migrate/
lib/
 |-assets/
 |-tasks/
log/
public/
spec/
 |- factories/
 |- helpers/
 |- mailers/
 |- models/
 |- requests/
 |- support/
 |- views/
tmp/
vendor/
```

## 3. <a name='CommonPatterns'></a>Common Patterns

- [Presenter](https://github.com/MarsBased/handbook/guides/patterns/rails/presenter.md)
- [Command](https://github.com/MarsBased/handbook/guides/patterns/rails/command.md)
- [Form Composition](https://github.com/MarsBased/handbook/guides/patterns/rails/form-composition.md)
- [Query Object](https://github.com/MarsBased/handbook/guides/patterns/rails/query-object.md)

### 3.1. <a name='DeviseIntegration'></a>Devise (Authentication)
Skip all the default routes generated by devise on `routes.rb` and create custom controllers and views according to the requirements.

#### `routes.rb`
```ruby
devise_for :users, skip: :all
resource :sign_up, only: %i(new create), path_names: { new: '' }
resource :session, only: %i(new create destroy), path: 'login', path_names: { new: '' }
resource :confirmation, only: %i(new create show)
resource :password, only: %i(new create edit update)
```

#### Sessions Controller example: `app/controllers/sessions_controller.rb`
```ruby
class SessionsController < ApplicationController

  prepend_before_action :allow_params_authentication!, only: :create
  prepend_before_action :require_no_authentication, only: %i(new create)

  def new
    @user = User.new
    @user.clean_up_passwords
  end

  def create
    @user = authenticate_user!(recall: 'sessions#new')
    sign_in(@user)

    redirect_to sign_up_path, notice: t('.ok')
  end

  def destroy
    sign_out(:user)

    redirect_to new_session_path, notice: t('.ok')
  end

end
```

#### New session view example: `app/views/sessions/new.html.erb`
```erb
<div class="box">
  <hgroup class="login__header">
    <h1><%= t('.title') %></h1>
  </hgroup>

  <%= simple_form_for(@user,
                    url: session_path,
                    html: { class: 'login__form' }) do |form| %>
    <%= form.input :email %>
    <%= form.input :password %>
    <%= form.submit t('.submit'), class: 'btn-primary is-block' %>
    <p class="login__link">
      <%= link_to 'Forgot Password?', new_password_path, class: 'link--secondary'%>
    </p>
  <% end%>
</div>
```

### 3.2. <a name='Testing'></a>Testing
We use the [Rspec](https://github.com/rspec/rspec) testing framework and usually we write these kind of tests:

* Unit tests for models, commands, jobs.
* System tests for integration.
* Request specs for APIs.
* Avoid controller tests: controllers functionality is already covered by integration specs.

### 3.2.1. <a name='TestingBestPractices'></a>Testing Best Practices
#### 3.2.1.1 <a name='UseLet'></a> Use let

When you have to assign a variable to test, instead of using a before each block, use let. It is memoized when used multiple times in one example, but not across examples.

```ruby
describe User do
  let(:user) { User.new(name: 'Rocky Balboa') }

  it 'has a name' do
    expect(user.name).to_not be_nil
  end
end
```

#### 3.2.1.2 <a name='UseFactories'></a> Use factories
Use [factory_bot](https://github.com/thoughtbot/factory_bot) to reduce the verbosity when working with models.

##### `spec/factories/user.rb`
```ruby
FactoryBot.define do
  name { 'Rocky Balboa '}
  age { 30 }
  active { true }
  role { :developer }
end
```

##### Using the factory
```ruby
user = FactoryBot.create(:user, name: 'John Rambo') # The rest of attributes are already set
```

#### 3.2.1.3 <a name='DescribeMethods'></a> Describe Methods
When testing a method, create a describe block with the name of the method and place the specs inside. Use "." as prefix for class methods and "#" as prefix for instance methods.

```ruby
describe ".authenticate" do
  it 'returns true when the user is active' { ... }
  it 'returns false when the user is deleted' { ... }
end

describe "#generate_export" do
  it 'returns an empty array when there are not users' { ... }
  it 'returns the list of active users' { ... }
end
```

## 4. <a name='Gems'></a>Gems
* General
  * [Keynote](https://github.com/rf-/keynote) for presenters.
  * [Simple form](https://github.com/heartcombo/simple_form) for form generation.
  * [Dotenv + dotenv-rails](https://github.com/bkeepers/dotenv) for environment variables.
  * [Activeadmin](https://github.com/activeadmin/activeadmin)  for admin panels.
  * [Devise](https://github.com/heartcombo/devise) for authentication.
  * [Sidekiq](https://github.com/mperham/sidekiq) for background jobs.
  * [Sidekiq-cron](https://github.com/ondrejbartas/sidekiq-cron) for scheduled jobs.
  * [Sidekiq-failures](https://github.com/mhfs/sidekiq-failures) for error tracking in background jobs.
  * [Shrine](https://github.com/shrinerb/shrine) for file uploads.
  * [Http (http-rb)](https://github.com/httprb/http) for http calls.
  * [Friendly_id](https://github.com/norman/friendly_id) for slugged url generation.
  * [Kaminari](https://github.com/kaminari/kaminari) for pagination.
  * [Jbuilder](https://github.com/rails/jbuilder) for JSON API responses.
  * [Pundit](https://github.com/varvet/pundit) for authorization.

* Testing:
  * [Rspec](https://github.com/rspec/rspec-rails) testing framework.
  * [FactoryBot](https://github.com/thoughtbot/factory_bot) for factories.
  * [Webmock (not VCR)](https://github.com/bblimke/webmock) to mock external HTTP requests.
  * [Capybara](https://github.com/teamcapybara/capybara) for integration tests.

* Dev
  * [Better_errors](https://github.com/BetterErrors/better_errors) for error enhancements.
  * [Pry + pry-rails](https://github.com/pry/pry) for a better console.
  * [Pry-byebug](https://github.com/deivid-rodriguez/pry-byebug) for console debugging.
  * [Bullet](https://github.com/flyerhzm/bullet) to detect N+1 queries.
  * [PgHero](https://github.com/ankane/pghero) for database insights.
