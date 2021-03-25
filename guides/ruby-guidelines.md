# Ruby guidelines

Resposinble: Jose Luis

Reference structure https://github.com/MarsBased/marsgular/blob/master/docs/ANGULAR_STYLE_GUIDE.md (open to modification, but David might get mad at you)

Ruby and Rails

Add and follow the official MarsBased Rubocop configuration (link: https://github.com/MarsBased/marstyle/blob/master/ruby/.rubocop.yml), where most of do's and dont's are already defined. Remark the 2 most big style principles:
  * single quotes when possible.
  * max line length of 90 characters.

## Do's and Don'ts

Do's
* Environment variables with dotenv.

Don'ts
* Never use .all without limiting the results or loading in batches.
* We don't use Rails model callbacks unless it's related to data persistence.
  * We specially avoid side effects like sending an e-mail.
* Don't write queries manually unless strictly necessary. Use Active Record queries as much as possible.
  * Code samples of Active Record query vs manual query like where('created_at < ?', DateTime.current)
  * When using Active Record we have the full power of it. For example if we have a custom serialization for a column, Active Record will automatically convert the value when writing queries.


## Common patterns

* Devise (authentication)
  * We have a custom way to build the integration with Devise by using custom controllers and views.
  * Check out the code on Rosetta and write an explanation / code examples.

* Testing
  * Unit tests for models, commands, jobs
  * System tests / Request specs (for API)
  * NOT controller tests

## Libraries

* Keynote for presenters
  * https://github.com/rf-/keynote
* simple_form
* Dotenv + dotenv-rails
* Activeadmin for admin panels
* Devise for authentication
* Sidekiq for background jobs
* Sidekiq-cron for scheduled jobs
* sidekiq-failures
* Shrine for uploads
* Http (http-rb) for http calls
* Testing:
  * webmock (not VCR)
  * Rspec
  * FactoryBot

More?
