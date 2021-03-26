# Back-end development guidelines

## Do's and Don'ts

Do's
* Always be looking at the applications logs while developing.
  * Look for N+1 queries
  * Look for warnings, etc.
* Use REST routes always if possible (a resource does not need to be an entity backed by the DB, an "export" can be a resource for example).
* Always use i18n from the get-go even if building for a single language.

Don'ts
* We try to avoid writing code that has unexpected side effects (sending an e-mail, making an API call) as much as possible. In particular this affects the usage of callbacks. We minimize the use of model callbacks and only use them to do some calculation at the persistence layer or some simple operation.


## Common patterns

* Database: Postgresql unless there is a project requirement that specifies to use another database engine, or use an existing database.

* Redis (describe common usages: temporary blocking access to resources, mutex locking for background jobs, etc.)

* Services:
  * Sentry for error reporting
  * AWS S3 for uploads
  * CloudFlare for CDN / reverse proxy
  * Github Actions or Circle CI for CI
  * Mailgun for email sending
  * Papertrail for logs
  * NewRelic / Scout for monitoring

* Usage of commands / services to keep controllers thin and models responsible mainly for persistence.
  * Don't use commands for everything. Limit their usage when you cannot achieve the same functionality by using the ORM directly by the controller.
  * When you have 2 or more related commands, namespace them into the same module (Users, Purchases, etc) to prevent a huge commands folder difficult to manage. If you cannot find a command in a big project, you cannot reuse it.

* Usage of presenters: keep views clean.
