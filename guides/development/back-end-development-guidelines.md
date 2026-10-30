# Back-end development guidelines

These guidelines apply to all our back-end stacks: Ruby on Rails, TypeScript (Node.js) and Python. Each section gives the principle first, then the tools that we use in each stack.

For stack-specific details, read also:

- [Ruby & Rails guidelines](/guides/development/ruby-guidelines.md) and the [ActiveRecord guide](/guides/development/activerecord-guide.md)
- [TypeScript guidelines](/guides/typescript-guidelines.md)
- [Testing guidelines](/guides/development/testing-guidelines.md)

## Do's and Don'ts

Do's

- Always look at the application logs while you develop. Look for warnings, slow queries and unexpected errors.
- Detect N+1 queries automatically. Do not rely only on the logs. Refer to [N+1 queries](#n1-queries).
- Use REST routes always if possible (a resource does not need to be an entity backed by the DB, an "export" can be a resource for example).
- Always use i18n from the get-go even if building for a single language.

Don'ts

- We try to avoid writing code that has unexpected side effects (sending an e-mail, making an API call) as much as possible. In particular this affects the usage of model callbacks (Rails callbacks, ORM hooks in TypeScript, Django signals in Python). We minimize their use and only use them to do some calculation at the persistence layer or some simple operation.

## Common patterns

- Database: [PostgreSQL](https://www.postgresql.org/) unless there is a project requirement that specifies to use another database engine, or use an existing database.

- In-memory data store: [Valkey](https://valkey.io/) for new projects, [Redis](https://redis.io/) in existing projects. Refer to [Redis and Valkey](#redis-and-valkey).

- Services:

  - MarsBased self-hosted tracking solution or [Sentry](https://sentry.io/) for error reporting
  - [Wasabi](https://wasabi.com/) or [AWS S3](https://aws.amazon.com/s3/) for uploads
  - [Cloudflare](https://www.cloudflare.com/) for CDN / reverse proxy. If the final users are from Spain we avoid Cloudflare as it can be blocked by Spanish ISPs.
  - [GitHub Actions](https://github.com/features/actions) for CI
  - [Mailgun](https://www.mailgun.com/) for email sending
  - Refer to [Observability](#observability) for monitoring, metrics and logs.

- Usage of commands / services to keep controllers thin and models responsible mainly for persistence.

  - Use a command when the action spans several models, has side effects, or is reused. Otherwise call the ORM from the controller.
  - When you have 2 or more related commands, namespace them into the same module (Users, Purchases, etc) to prevent a huge commands folder difficult to manage. If you cannot find a command in a big project, you cannot reuse it.
  - Rails: refer to the [command pattern](/guides/patterns/rails/command.md).
  - TypeScript and Python: use plain service functions or classes, grouped in one folder per domain (for example `users/`, `purchases/`).

## Redis and Valkey

### Licenses

In March 2024, Redis changed its license from BSD to a dual RSALv2 / SSPLv1 license. Redis 8 (2025) added AGPLv3 as a third option. [Valkey](https://valkey.io/) is a fork of Redis 7.2 under the Linux Foundation. It keeps the BSD-3 license.

| | Redis 7.4+ | Redis 8+ | Valkey |
|---|---|---|---|
| License | RSALv2 or SSPLv1 | RSALv2, SSPLv1 or AGPLv3 | BSD-3 |
| Open source (OSI) | No | Yes, with AGPLv3 | Yes |
| Main restriction | You cannot sell Redis as a managed service | AGPLv3: if you change Redis and give users network access to it, you must give them the source | None |

The restrictions apply when you offer Redis as a service, or when you change Redis and give users access to it. They do not apply when an application only connects to Redis. Thus the legal risk for our projects is low.

Our rules:

- Use Valkey for new projects. It is compatible with the Redis protocol, so the usual clients (`redis-rb`, `ioredis`, `redis-py`) and libraries (Sidekiq, BullMQ, Celery) work without changes.
- Keep Redis in existing projects. Change to Valkey only when the project has a reason, for example a hosting change.
- Before you choose Valkey, make sure that the hosting provider supports it (for example AWS ElastiCache and Google Memorystore do).

In the rest of this guide, "Redis" means Redis or Valkey.

### Common uses

- **Caching**: Store frequently accessed data (API responses, computed values, database query results) to reduce load on the database and improve response times.
- **Background job queues**: Many job processing systems use Redis to manage queues. Configure separate queues for different job priorities (default, mailers, critical, low).
- **Mutex locking**: Prevent duplicate work when multiple workers can process the same resource at the same time. Refer to [Locks](#locks).
- **Temporary blocking/rate limiting**: Block access to resources temporarily (e.g., prevent duplicate form submissions, implement API rate limiting, or throttle requests per user/IP).
- **Session storage**: Store user sessions in Redis for faster access and easier horizontal scaling across multiple application servers.
- **Real-time features**: Pub/Sub for WebSocket connections or inter-process communication.

### Eviction policy

A cache and a queue need different configurations:

- A cache must evict old keys when memory is full. Use `maxmemory-policy allkeys-lru`.
- Redis must never evict queues, sessions, locks and rate-limit counters. Use `maxmemory-policy noeviction`.

Do not use one instance for a cache and a queue. With `allkeys-lru`, a memory spike in the cache silently deletes jobs and logs users out. With `noeviction`, a full cache makes writes fail.

- Use two instances: one for the cache, one for the other data.
- Logical databases (`/0`, `/1`) in one instance share one `maxmemory-policy`. They do not count as two instances.
- Rails `rate_limit` and Rack::Attack use the cache store by default. Give them the non-cache instance: the `store:` option of `rate_limit`, or `Rack::Attack.cache.store`.

If the project can have only one instance:

- Use `noeviction`.
- Set a TTL on all cache keys, for example `config.cache_store = :redis_cache_store, { url: ENV["REDIS_URL"], expires_in: 1.day }` in Rails.
- Set `maxmemory` with free space above the normal use.
- Add an alert on the memory use. A cache spike can still fill the memory, and then the job queue stops.

### Locks

A lock in a single Redis instance with a TTL is not safe for correctness. A failover can lose the lock. A long pause in the process (garbage collection, a slow network) can let the TTL expire while the process still does the work. Then two processes hold the lock at the same time.

- Use Redis locks for efficiency only, for example to prevent two workers from generating the same report.
- For correctness (payments, stock, balances), use the database:
  - unique constraints
  - row locks (`SELECT ... FOR UPDATE`)
  - PostgreSQL advisory locks
  - optimistic locking with a version column
- Make the job idempotent, so a duplicate run does no damage. Refer to [Background jobs](#background-jobs).

### Do you need Redis?

Some projects do not need Redis. PostgreSQL can be the queue, the cache and the Pub/Sub back end. One less service means less cost and less maintenance.

- Rails 8 ships database-backed adapters: [Solid Queue](https://github.com/rails/solid_queue), [Solid Cache](https://github.com/rails/solid_cache) and [Solid Cable](https://github.com/rails/solid_cable). They also work in Rails 7.1+. Our default stays Sidekiq with Redis. Consider the Solid adapters for small projects with a low job volume.
- TypeScript: [pg-boss](https://github.com/timgit/pg-boss) and [Graphile Worker](https://worker.graphile.org/) are job queues on PostgreSQL.
- Python: [Procrastinate](https://procrastinate.readthedocs.io/) is a job queue on PostgreSQL. Django 6.0 adds a tasks API (`django.tasks`). For production, it needs a third-party back end with a worker.

## Authentication and authorization

- Do not write your own authentication. Use a library that the community maintains.
- Check authorization in each action. Use one policy object per resource, not checks spread across controllers.
- Deny access by default. Make tests that prove a user cannot access the records of a different user.
- Accept only the parameters that you expect. Never pass the request body directly to the ORM.

| | Rails | TypeScript | Python |
|---|---|---|---|
| Authentication | [Devise](https://github.com/heartcombo/devise), Rails 8 authentication generator | [Passport](https://www.passportjs.org/), [Better Auth](https://www.better-auth.com/) | Django auth, [django-allauth](https://allauth.org/), [Authlib](https://authlib.org/) for OAuth and OpenID Connect |
| Authorization | [Pundit](https://github.com/varvet/pundit), [ActionPolicy](https://actionpolicy.evilmartians.io/) | [CASL](https://casl.js.org/) | [django-rules](https://github.com/dfunckt/django-rules), policy functions |
| Allowed parameters | Strong parameters (`params.expect`, `params.require.permit`) | [Zod](https://zod.dev/) schemas | [Pydantic](https://docs.pydantic.dev/) models, DRF serializers |

Refer also to the [security guides](/guides/security/README.md), in particular [user accounts protection](/guides/security/user_accounts_protection.md).

### Rate limiting

Limit the requests to sensitive endpoints: sign in, sign up, password reset, and public APIs. Store the counters in Redis or in the database. Do not store them in the process memory, because the application runs in more than one process.

- Rails: the built-in `rate_limit` in controllers (Rails 7.2+), or [Rack::Attack](https://github.com/rack/rack-attack).
- TypeScript: [rate-limiter-flexible](https://github.com/animir/node-rate-limiter-flexible), or the module of the framework (for example `@nestjs/throttler`).
- Python: [django-ratelimit](https://django-ratelimit.readthedocs.io/), [SlowAPI](https://github.com/laurentS/slowapi) for FastAPI.

## Background jobs

| | Rails | TypeScript | Python |
|---|---|---|---|
| Job library | [Sidekiq](https://github.com/sidekiq/sidekiq) with Active Job | [BullMQ](https://docs.bullmq.io/) | [Celery](https://docs.celeryq.dev/) |
| Retries | `retry_on`, `discard_on` | `attempts`, `backoff` | `autoretry_for`, `retry_backoff` |

### Idempotency

A job can run more than once: retries, a worker crash, a deploy. Make each job idempotent, so a second run gives the same result as the first run.

- Pass IDs as arguments, not full objects. Load the record again in the job.
- Claim the work in one atomic step before you do it. A separate check (`return if invoice.sent?`) is not sufficient, because two runs can pass the check at the same time:

  ```ruby
  claimed = Invoice.where(id: invoice_id, sent_at: nil).update_all(sent_at: Time.current) == 1
  return unless claimed
  ```

- Use an idempotency key when you call an external API that supports it (for example Stripe).
- Use unique constraints to prevent duplicate records.

### Retries

- Retry errors that can go away: timeouts, rate limits, network errors.
- Do not retry errors that cannot go away: validation errors, a deleted record. Discard the job and log the error.
- Use exponential backoff and a maximum number of attempts.
- Send the jobs that fail all attempts to the error tracker, and to a dead-letter queue if the library has one.

### Enqueue after commit

If you enqueue a job inside a database transaction, the worker can start before the commit. Then the worker cannot find the record. If the transaction rolls back, the job runs for a record that does not exist.

Enqueue the job in the command, after the transaction:

```ruby
# Rails
order = Order.transaction { Order.create!(order_params) }
OrderConfirmationJob.perform_later(order.id)
```

```typescript
// TypeScript (Drizzle + BullMQ)
const [order] = await db.transaction(async (tx) => {
  return tx.insert(orders).values(data).returning();
});
await queue.add('order-confirmation', { orderId: order.id });
```

```python
# Python (Django + Celery)
with transaction.atomic():
    order = Order.objects.create(**data)
    transaction.on_commit(lambda: send_order_confirmation.delay(order.id))
```

In Rails 7.2+, you can also set `self.enqueue_after_transaction_commit = true` in the job class. The default value changes between Rails versions, so set it explicitly.

When the job must never get lost, use the [transactional outbox pattern](https://microservices.io/patterns/data/transactional-outbox.html). Write the job to a database table in the same transaction. Then a separate process enqueues it.

## N+1 queries

Do not rely on somebody to watch the logs. Detect N+1 queries automatically, in development and in the test suite.

| Stack | Tool | How it works |
|---|---|---|
| Rails | [`strict_loading`](https://guides.rubyonrails.org/active_record_querying.html#strict-loading) | Raises an error or logs a warning when the code lazy-loads an association. In the default mode (`:all`), it also catches single lazy loads that are not N+1 queries. |
| Rails | [Prosopite](https://github.com/charkost/prosopite) | Detects N+1 queries with no false positives. Use it in the test suite. |
| Rails | [Bullet](https://github.com/flyerhzm/bullet) | Detects N+1 queries and unused eager loading. |
| Python (SQLAlchemy) | `lazy="raise"`, `raiseload()` | Raises an error when the code lazy-loads a relationship. Same idea as `strict_loading`. |
| Python (Django) | [django-zeal](https://github.com/taobojlen/django-zeal) | Detects N+1 queries in development and tests. |
| Python (Django) | `assertNumQueries` | Makes a test fail when the number of queries changes. |
| TypeScript | Query count in tests | Count the queries with the ORM logger (for example the Drizzle `logger` option) and assert the number. |
| All | [Sentry](https://docs.sentry.io/product/issues/issue-details/performance-issues/n-one-queries/) performance issues | Detects N+1 queries in production. Make sure that the SDK of the project supports it. |

Our rules:

- Rails: in new projects, turn on `strict_loading` for N+1 queries only:

  ```ruby
  # config/application.rb
  config.active_record.strict_loading_by_default = true
  config.active_record.strict_loading_mode = :n_plus_one_only

  # config/environments/production.rb
  config.active_record.action_on_strict_loading_violation = :log
  ```

- Rails: in existing projects, add Prosopite or Bullet to the test suite.
- Python: use `lazy="raise"` on SQLAlchemy relationships, or django-zeal in Django projects.
- TypeScript: for each list endpoint, add a test that asserts the number of queries.

The ORMs in TypeScript (Drizzle, Prisma, TypeORM) have no common N+1 detector. If a project uses GraphQL, use [DataLoader](https://github.com/graphql/dataloader) to batch the queries.

For ways to fix N+1 queries in Rails, refer to the [ActiveRecord guide](/guides/development/activerecord-guide.md#avoiding-n1-queries).

## API conventions

- **Versioning**: put the version in the URL (`/api/v1/...`). Make a new version only for changes that break clients. Adding a field does not break clients.
- **Pagination**: paginate all list endpoints. Use cursor pagination for large lists or lists that change frequently. Use offset pagination (`page`, `per_page`) for small lists and admin panels. Put a maximum on the page size.
- **Errors**: use the correct HTTP status code. Return the error body in the [Problem Details format (RFC 9457)](https://www.rfc-editor.org/rfc/rfc9457), with the `Content-Type: application/problem+json` header:

  ```json
  {
    "type": "https://example.com/errors/validation",
    "title": "Validation failed",
    "status": 422,
    "errors": [{ "pointer": "#/email", "detail": "is already taken" }]
  }
  ```

- **Serialization**: use a serializer to define the output. Never return the model directly, because it can expose private columns.
- **Naming**: use `snake_case` or `camelCase` for JSON keys, and use the same one in all endpoints of the project.
- **Documentation**: describe the API with [OpenAPI](https://www.openapis.org/). Generate the specification from the code or from the tests when possible.

| | Rails | TypeScript | Python |
|---|---|---|---|
| Serialization | [Jbuilder](https://github.com/rails/jbuilder), [Alba](https://github.com/okuramasafumi/alba) | [Zod](https://zod.dev/) schemas | [Pydantic](https://docs.pydantic.dev/), DRF serializers |
| Pagination | [Kaminari](https://github.com/kaminari/kaminari), [Pagy](https://github.com/ddnexus/pagy) | `limit` with a cursor column in the ORM query | DRF pagination, [fastapi-pagination](https://github.com/uriyyo/fastapi-pagination) |
| OpenAPI | [rswag](https://github.com/rswag/rswag) | [zod-to-openapi](https://github.com/asteasolutions/zod-to-openapi) | Built into FastAPI, [drf-spectacular](https://github.com/tfranzel/drf-spectacular) |

## Data migrations

### Zero-downtime changes

During a deploy, the old code and the new code run at the same time against the same database. Each migration must work with both versions of the code.

Use the expand and contract pattern. For example, to rename a column:

1. Add the new column.
1. Write to both columns.
1. Backfill the new column.
1. Read from the new column.
1. Stop writing to the old column.
1. Rails: add the old column to `self.ignored_columns`. If you do not, the old processes fail because their cached schema still has the column.
1. Remove the old column in a later deploy.

Safe procedures for risky operations in PostgreSQL:

- Add indexes with `CREATE INDEX CONCURRENTLY`. In Rails, use `algorithm: :concurrently` and `disable_ddl_transaction!` in the migration.
- Add a `NOT NULL` constraint in four steps:
  1. Add a `CHECK (column IS NOT NULL)` constraint as `NOT VALID`.
  1. Validate the constraint.
  1. Run `ALTER COLUMN ... SET NOT NULL`. PostgreSQL 12+ uses the valid constraint and does not scan the table.
  1. Remove the `CHECK` constraint.
- Do not change the type of a column on a large table. Add a new column instead.
- Set a `lock_timeout`, so a blocked migration fails fast and does not block the full table.

Use a linter that finds these problems before the deploy:

- Rails: [strong_migrations](https://github.com/ankane/strong_migrations).
- Python (Django): [django-pg-zero-downtime-migrations](https://github.com/tbicr/django-pg-zero-downtime-migrations).
- All stacks: [Squawk](https://squawkhq.com/) checks SQL migration files.

### Backfills

- Keep data changes out of schema migrations. A long backfill in a migration blocks the deploy.
- Run backfills as a separate task or job, in batches (for example 1,000 rows per batch).
- Make backfills idempotent, so you can run them again after a failure.
- Rails: [maintenance_tasks](https://github.com/Shopify/maintenance_tasks). TypeScript and Python: a script or a job in the project.

### Reversibility

- Write a `down` step for each schema migration, or mark it as irreversible on purpose.
- Test the rollback in development before you merge.
- You cannot reverse a migration that deletes data. Make a backup before you run it in production.

## Observability

The hosting service gives basic metrics and logs. That is not sufficient to find the cause of a problem in production. Each project must have:

- **Error tracking**: Sentry or the MarsBased self-hosted solution, in the web processes and in the workers.
- **Structured logs**: JSON logs with a request ID in each line. Use the same request ID in the jobs that the request enqueues.
- **Health check**: an endpoint (for example `/up`) that the hosting service and the uptime monitor call.
- **Uptime monitor**: an external service that sends an alert when the application is down.
- **Alerts**: an alert for the error rate, the response time and the queue size. Send the alerts to the project Slack channel.

| | Rails | TypeScript | Python |
|---|---|---|---|
| Structured logs | [Lograge](https://github.com/roidrage/lograge), [Rails Semantic Logger](https://github.com/reidmorrison/rails_semantic_logger) | [Pino](https://getpino.io/) | [structlog](https://www.structlog.org/) |

Do not log personal data or secrets. Refer to [sensitive data logging](/guides/security/sensitive-data-logging.md).

## Data residency and GDPR

Most of our clients are in the EU. Personal data of EU users must stay in the EU. Send it outside the EU only to vendors with a valid transfer mechanism.

- Choose an EU region for the database, the file storage, the backups and the Redis instance.
- Choose the EU region of the email vendor. Mailgun has an EU region (`api.eu.mailgun.net`). You must make the domain in that region.
- Choose the EU data region in Sentry (`de.sentry.io`). You choose it when you make the organization, and you cannot change it later.
- Sign a Data Processing Agreement (DPA) with each vendor that processes personal data.
- For vendors outside the EU, use a transfer mechanism. Examples are the [EU-US Data Privacy Framework](https://www.dataprivacyframework.gov/) and Standard Contractual Clauses.
- Keep a list of the vendors (sub-processors) of each project. The client needs it for its own GDPR records.
- Error trackers and log services also receive personal data. Apply the same rules to them.
- Define how long you keep the data, and delete it after that period.

Refer also to [3rd party software integrations](/guides/security/3rd_party_software_integrations.md).
