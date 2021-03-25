# Form composition pattern

This pattern is used to have multiple models being saved in the same form without writing additional logic that the one Rails already provides.

## Solution overview

We use `ActiveModel::Model` to create a virtual model that can be used with Rails form helpers as if it was a regular Active Record model.
This model has a `save` method to simulate saving the record to the database and allow to use it from a controller in the same way we use Active Record models.

This pattern uses form objects which are placed in the `app/forms` directory.

## Usage: Sign up from saving two models (user and organization)

### `app/forms/signup_form.rb`

```ruby
# frozen_string_literal: true

class SignUpForm

  include ActiveModel::Model

  def save # (1)
    user.save
  end

  def user # (2)
    @user ||= User.new
  end

  def user_attributes=(attributes) # (3)
    user.assign_attributes(attributes)
  end

  def organization # (2)
    @organization ||= user.memberships.build(role: :owner).build_organization
  end

  def organization_attributes=(attributes) # (3)
    organization.assign_attributes(attributes)
  end

end
```

- (1) The save method must save all the models and return true or false. In the example, saving the user saves the organization too. If you need to save non related models you need to wrap the save methods inside a transaction. For example:
```
def save
  ActiveRecord::Base.transaction do
    user.save && organization.save or fail ActiveRecord::Rollback
  end
end
```
Checking if the records are valid before saving is not enough as unexpected race conditions could happen leaving inconsistent data in the database.
- (2) Getters need to be created for every model we want in the form. As this is a create form, we are instantiating the models directly in the form.
- (3) For every entity we need to create a entity_attributes=(attributes) method. This method will be used by Rails via ActiveModel::Model to treat the models as nested forms.

## `app/controllers/signups_controller.rb`

```ruby
# frozen_string_literal: true

class SignUpsController < ApplicationController

  def new
    @sign_up_form = SignUpForm.new
  end

  def create # (1)
    @sign_up_form = SignUpForm.new(signup_params)

    if @sign_up_form.save
      sign_in(@sign_up_form.user)
      redirect_to dashboard_path
    else
      render :new
    end
  end

  private

  def signup_params # (1)
    params.require(:sign_up_form).permit(
      user_attributes: %i(email password),
      organization_attributes: %i(name)
    )
  end

end
```

- (1) As we can see the form object is treated as any other Active Record object. Parameters are received in the same way and we "save" it in the same way.

## `app/views/signups/new.html.erb`

```ruby
<% # (1) %>
<%= simple_form_for(@sign_up_form,
                    url: sign_up_path) do |form| %>
  <% # (2) %>
  <%= form.simple_fields_for :user do |user_form| %>
    <%= user_form.input :email %>
    <%= user_form.input :password %>
  <% end %>
  <% # (2) %>
  <%= form.simple_fields_for :organization do |org_form| %>
    <%= org_form.input :name %>
  <% end %>
  <%= form.submit %>
<% end %>
```

- (1) Notice that we are using the sign_up_form instance variable for the form.
- (2) User and organization fields will be accessed via simple_fields_for. One of the advantages of the pattern is that the errors of the user belong to the user and not to the signup form. The same happens with the organization.

## Usage: Edit profile form

### `app/forms/profile_form.rb`

```ruby
# frozen_string_literal: true

class ProfileForm

  include ActiveModel::Model

  attr_accessor :user # (1)

  def save
    user.save
  end

  def organization # (2)
    @organization ||= user.organization
  end

  def organization_attributes=(attributes)
    organization.assign_attributes(attributes)
  end

  def user_attributes=(attributes)
    user.assign_attributes(attributes)
  end

end
```

- (1) For edit forms, we need attr_accessors for every entity that we want to update and initialize them in the controllers or other classes before using them.
- (2) As the organization can still be accessed from the user model, we don't need to create an attr_accessor.

### `app/controllers/profiles_controller.rb`

```ruby
# frozen_string_literal: true

class ProfilesController < ApplicationController

  def edit
    @profile_form = ProfileForm.new(user: current_user) # (1)
  end

  def update
    @profile_form = ProfileForm.new(user: current_user) # (1)
    @profile_form.attributes = profile_params

    if @profile_form.save
      redirect_to profile_path, notice: t('.success')
    else
      render :edit
    end
  end

  private

  def profile_params
    params.require(:profile_form).permit(
      user_attributes: %i(email),
      organization_attributes: %i(name)
    )
  end

end
```

- (1) We are using the ProfileForm user attr_accessor to configure the user to be edited.
