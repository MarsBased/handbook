# Presenter pattern

A presenter pattern helps to separate business logic (model) and presentation logic (presenter)

A presenter is meant to be used from the views. If there are methods that need to be used from services or commands, these methods should be placed in the model, or another class instead.

## Solution overview

We chose [Keynote](https://github.com/rf-/keynote) gem to implement presenters:

#### `./Gemfile`

```ruby
# frozen_string_literal: true

source 'https://rubygems.org'

gem 'keynote'
```

Considered alternatives:

- [Draper](https://github.com/drapergem/draper)

## Usage: presenter for a model

It decorates a Rails model, that should be passed when creating the presenter.

#### `app/presenters/user_presenter.rb`

```ruby
# frozen_string_literal: true

class UserPresenter < Keynote::Presenter

  presents :user # (1)

  def full_name
    [user.title, user.first_name, user.middle_name, user.last_name].compact.join(' ')
  end

  def city_state_zip
    [user.city, user.state, user.zip_code].compact.join(', ')
  end

  def formatted_phone
    number_to_phone(user.phone, area_code: true) # (2)
  end

 end
```

- (1) Decorates a user
- (2) Rails view helpers are available on the presenters

## Usage: presenter with no model

This presenter is not decorating any model or class.
It can be understood as a collection of related and encapsulated methods to be used
in the views, with the ability to create HTML from ruby code.

#### `app/presenters/user_presenter.rb`

```ruby
# frozen_string_literal: true

class NavbarPresenter < Keynote::Presenter

  def section_for(step, steps: Array(step), url: step)
    build_html do
      li class: pill_class(steps) do
        link_to(url) do
          build_html do
            span class: 'nav-steps__step-number'
            span t(".#{step}"), class: 'nav-steps__step-title'
            span class: 'icon-check'
          end
        end
      end
    end
  end

  def active?(section)
    # ...
  end

  private

  def pill_class(sections)
    # ...
  end

end
```

## Usage: use presenters in views

Use the `present` helper method (provided by Keynote) to create presenters.

#### `app/views/_navbar.html.erb`

```erb
<div class="main-content">
  <ul class="nav nav-steps">
    <%= present(:navbar).section_for(:personal_info) %>
    ...
  </ul>
  <div class="main-content__user">
    <%= present(@user).full_name %>
  </div>
</div>
```

⚠️Some of our code bases uses the `k` method alias insted of `present`, although is now discouraged ️️⚠️

## FAQ

### Are decorators cached?

Yes, this is the recommended approach:

```erb
<%= present(@user).full_name %>
<%= present(@user).formatted_phone %>
```
