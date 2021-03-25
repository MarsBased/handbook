# Ruby guidelines

We follow the `Rubocop` official and opinionated [Rubocop Ruby coding style guide](https://github.com/rubocop/ruby-style-guide) as the primary source of best practices and conventions.

- 1. [Do's and Don'ts](#DosandDonts)
  - 1.1. [Environment Variables](#Environmentvars)
  - 1.2. [Loading in batches](#Batchloading)
  - 1.3. [Avoid unnecessary callbacks](#Modelcallbacks)
  - 1.4. [Manual queries](#Manualqueries)
  - 1.5. [Size instead of count](#SizeCount)
  - 1.6. [Avoid N+1 Queries with includes](#UseIncludes)
  - 1.7. [Avoid Default Scope](#AvoidDefaultScope)
  - 1.8. [Use find_by for instead where().first](#FindByInsteadWhere)
  - 1.9. [Check constraints](#CheckConstraints)
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

Add and follow the official [MarsBased Rubocop  configuration](hhttps://github.com/MarsBased/marstyle/blob/master/ruby/.rubocop.yml), where most of do's and dont's are already defined, highlighting this two do's.

- Use single quotes when possible.
- Apply a max length of 90 characters

### 1.1. <a name='Environmentvars'></a>Use Dotenv for environment variables

We use [Dotenv](https://github.com/bkeepers/dotenv) gem for managing the environment variables.

### 1.2. <a name='Batchloading'></a>Loading in batches

Don't iterate unlimited/big queries directly
```ruby
Car.all.each(&:start_engine!)
```
Use find in batches for loading big queries
```ruby
Car.find_in_batches do |batch|
  batch.each(&:start_engine!)
end
```
### 1.3. <a name='Modelcallbacks'></a>Avoid unnecessary callbacks
We don't use Rails model callbacks unless it's related to data persistence specially avoiding side effects like sending and e-email, etc.

Avoid callbacks like this:
```ruby
after_save :notify_user

def notify_user
  UserMailer.notify(user).deliver
end
```

### 1.4. <a name='Manualqueries'></a>Manual queries

Don't write queries manually unless strictly necessary.
```ruby
ActiveRecord::Base.connection.exec_query("SELECT * FROM users WHERE created_at < '#{DateTime.current}'")
```
Use Active Record queries as much as possible
```ruby
User.where('created_at < ?', DateTime.current)
```
When using Active Record we have the full power of it. For example if we have a custom serialization for a column, Active Record will automatically convert the value when writing queries.

### 1.5. <a name='SizeCount'></a>Size instead of count

Use `size` instead of `count` unless you are doing a direct count on a table. Using `count` always triggers a query while using `size` is able to use the cached values of a previous query.

Use this:
```ruby
Post.published.count
```
Instead of this:
```ruby
Post.published.size OK
```

### 1.6. <a name='UseIncludes'></a>Avoid N+1 Queries with includes
When you have to access to a relationship record of a collection, avoid N+1 query problems, loading relation  previously with `includes':

```ruby
User.includes(:posts).each do |user|
  user.posts.each do |post|
    p post.title
  end
end
```

### 1.7. <a name='AvoidDefaultScope'></a>Avoid Default Scope
In order to avoid unexpected and hidden behavior for avoid using default_scope and use named scopes and implicit calls:

Instead of:

```ruby
class User < ActiveRecord::Base
  default_scope { where(hidden: false) }
end
```
Use named scopes:
```ruby
class User < ActiveRecord::Base
  scope (:hidden), -> { where(hidden: false) }
end
```

### 1.8. <a name='FindByInsteadWhere'></a>Use find_by for instead where().first
 Don’t use where(…).first, use find_by instead. And similarly with Enumerable use find { ... }  instead of select { … }.first
```ruby
BAD
User.where(active: true).first

OK
User.find_by(active: true)
```
### 1.9. <a name='CheckConstraints'></a>Check constraints
Check that constraints are correct and that they match the validations. A typical example is adding a default without a not-null constraint.

## 2. <a name='Generalprojectorganizationandarchitecture'></a>General project organization and architecture

Follow the standard generated directory structure at project initialization with `rails new project_name` and described in [Ruby On Rails Guide](https://guides.rubyonrails.org/getting_started.html). Additionally:
- Services under the /app/services directory
- Commands under the /app/commands directory
- Presenters under the /app/presenters directory

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
test/
 |- controllers/
 |- fixtures/
 |- helpers/
 |- integration/
 |- mailers/
 |- models/
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
- [Presenter](https://github.com/MarsBased/patterns/blob/master/rails/presenter.md)
- [Command](https://github.com/MarsBased/patterns/blob/master/rails/command.md)
- [Form Composition](https://github.com/MarsBased/patterns/blob/master/rails/form-composition-pattern.md)
- [Query Object](https://github.com/MarsBased/patterns/blob/master/rails/query-object.md)
### 3.1. <a name='DeviseIntegration'></a>Devise (Authentication)
Skip all the default routes generated by devise on `routes.rb` and create custom controllers and views according to the requirements. You can review [Rosseta](https://github.com/MarsBased/rosetta) project for a real example.

routes.rb
```ruby
devise_for :users, skip: :all
resource :sign_up, only: %i(new create), path_names: { new: '' }
resource :session, only: %i(new create destroy), path: 'login', path_names: { new: '' }
resource :confirmation, only: %i(new create show)
resource :password, only: %i(new create edit update)
```
Sessions Controller example:
```ruby
class SessionsController < ApplicationController

  layout 'nude'

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
Sessions new view example
```erb
<div class="box">
  <hgroup class="login__header">
    <h1><%= t('.title') %></h1>
  </hgroup>

  <%= simple_form_for(@user,
                    url: session_path,
                    builder: MinimalFormBuilder,
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
  We use Rspec as a testing framework and usuarlly the kind of tests we do are:

  * Unit tests for models, commands, jobs
  * System tests for integration
  * Request specs for APIs
  * Avoid controller tests
### 3.2.1. <a name='TestingBestPractices'></a>Testing Best Practices
#### 3.2.1.1 <a name='UseLet'></a> Use let

When you have to assign a variable to test, instead of using a before each block, use let. It is memoized when used multiple times in one example, but not across examples.
```ruby
describe User
  let(:user) { User.locate }

  it 'should have a name' do
    user.name.should_not be_nil
  end
end
```
#### 3.2.1.2 <a name='UseFactories'></a> Use factories
Use factory_girl to reduce the verbosity when working with models.

```ruby
user = Factory.create(:user)
```
#### 3.2.1.3 <a name='DescribeMethods'></a> Describe Methods
Keep clear the methods you are describing using "." as prefix for class methods and "#" as prefix for instance methods.

Use
```ruby
describe ".authenticate" do
describe "#save" do
```
instead of
```ruby
describe "the authenticate method for User" do
describe "the save method for User" do
```
## 4. <a name='Gems'></a>Gems
* General
  * [Keynote](https://github.com/rf-/keynote) for presenters
  * [Simple form](https://github.com/heartcombo/simple_form) for form generation
  * [Dotenv + dotenv-rails](https://github.com/bkeepers/dotenv) for environment variables
  * [Activeadmin](https://github.com/activeadmin/activeadmin)  for admin panels
  * [Devise](https://github.com/heartcombo/devise) for authentication
  * [Sidekiq](https://github.com/mperham/sidekiq) for background jobs
  * [Sidekiq-cron](https://github.com/ondrejbartas/sidekiq-cron) for scheduled jobs
  * [Sidekiq-failures](https://github.com/mhfs/sidekiq-failures) for error tracking
  * [Shrine](https://github.com/shrinerb/shrine) for uploads
  * [Http (http-rb)](https://github.com/httprb/http) for http calls
  * [Friendly_id](https://github.com/norman/friendly_id) for slugged url generation
  * [Kaminari](https://github.com/kaminari/kaminari) for pagination
  * [Jbuilder](https://github.com/rails/jbuilder) for JSON API responses
  * [Pundit](https://github.com/varvet/pundit) for authorization

* Testing:
  * [Rspec](https://github.com/rspec/rspec-rails) testing framework
  * [FactoryBot](https://github.com/thoughtbot/factory_bot) for fixtures
  * [Webmock (not VCR)](https://github.com/bblimke/webmock) for mocks
  * [Capybara](https://github.com/teamcapybara/capybara) for integration
* Dev
  * [Better_errors](https://github.com/BetterErrors/better_errors) for error enhancements
  * [Pry + pry-rails](https://github.com/pry/pry) for a better console
  * [Pry-byebug](https://github.com/deivid-rodriguez/pry-byebug) for console debugging
  * [Bullet](https://github.com/flyerhzm/bullet) N+1 queries analyzer
  * [PgHero](https://github.com/ankane/pghero) for database insights




