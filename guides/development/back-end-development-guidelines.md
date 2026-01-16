# Back-end development guidelines

## Do's and Don'ts

Do's

- Always be looking at the applications logs while developing.
  - Look for N+1 queries
  - Look for warnings, etc.
- Use REST routes always if possible (a resource does not need to be an entity backed by the DB, an "export" can be a resource for example).
- Always use i18n from the get-go even if building for a single language.

Don'ts

- We try to avoid writing code that has unexpected side effects (sending an e-mail, making an API call) as much as possible. In particular this affects the usage of callbacks. We minimize the use of model callbacks and only use them to do some calculation at the persistence layer or some simple operation.

## Common patterns

- Database: [PostgreSQL](https://www.postgresql.org/) unless there is a project requirement that specifies to use another database engine, or use an existing database.

- [Redis](https://redis.io/): In-memory data store commonly used for:

  - **Caching**: Store frequently accessed data (API responses, computed values, database query results) to reduce load on the database and improve response times.
  - **Background job queues**: Many job processing systems use Redis to manage queues. Configure separate queues for different job priorities (default, mailers, critical, low).
  - **Mutex locking**: Prevent race conditions in background jobs using distributed locks. Essential when multiple workers might process the same resource simultaneously.
  - **Temporary blocking/rate limiting**: Block access to resources temporarily (e.g., prevent duplicate form submissions, implement API rate limiting, or throttle requests per user/IP).
  - **Session storage**: Store user sessions in Redis for faster access and easier horizontal scaling across multiple application servers.
  - **Real-time features**: Pub/Sub for WebSocket connections or inter-process communication.

- Services:

  - MarsBased self-hosted tracking solution or [Sentry](https://sentry.io/) for error reporting
  - [Wasabi](https://wasabi.com/) or [AWS S3](https://aws.amazon.com/s3/) for uploads
  - [Cloudflare](https://www.cloudflare.com/) for CDN / reverse proxy. If the final users are from Spain we avoid Cloudflare as it can be blocked by Spanish ISPs.
  - [GitHub Actions](https://github.com/features/actions) for CI
  - [Mailgun](https://www.mailgun.com/) for email sending
  - Rely on the hosting service for monitoring, metrics and logs. Advanced monitoring needs would require a dedicated service like [Datadog](https://www.datadoghq.com/).

- Usage of commands / services to keep controllers thin and models responsible mainly for persistence.

  - Don't use commands for everything. Limit their usage when you cannot achieve the same functionality by using the ORM directly by the controller.
  - When you have 2 or more related commands, namespace them into the same module (Users, Purchases, etc) to prevent a huge commands folder difficult to manage. If you cannot find a command in a big project, you cannot reuse it.
