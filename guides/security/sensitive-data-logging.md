# Sensitive Data in Logs

## Why it matters

Application logs often end up in centralized systems such as Datadog, CloudWatch, or ELK. These systems have broader access than the application itself. If sensitive data appears in logs, anyone with log access can read it.

Logs are also a common target in security breaches. An attacker who gets read access to logs can harvest credentials, tokens, and personal data.

Beyond security, there are legal risks:

- **GDPR** (Article 5) requires data minimization. You must log only what is necessary and justified. Log retention must follow a documented policy with clear deletion timelines.
- **PCI-DSS** forbids the storage of full card numbers, CVVs, or authentication data in any form. Logs are not an exception.

OWASP lists this problem under A09:2021 (Security Logging and Monitoring Failures).

## What must never appear in logs

- Passwords and password hashes
- Session tokens, access tokens, and refresh tokens
- API keys and encryption keys
- Credit card numbers, CVVs, and bank account data
- Social security numbers and government identifiers
- Health and medical data
- Database connection strings
- Full request bodies that contain any of the above
- Authorization headers and authentication cookies

The rule is simple: if data can identify, authenticate, or authorize a person, do not log it.

## Mitigation techniques

Use one or more of the following approaches:

- **Redact**: Replace the value with a placeholder such as `[FILTERED]` or `[REDACTED]`.
- **Mask**: Show only the last few characters (e.g., `****1234`).
- **Hash**: Log a SHA-256 hash of the value. This allows correlation without exposure.
- **Omit**: Do not include the field at all. This is the safest option for credentials.

## Ruby on Rails

### Configure parameter filters

Rails filters sensitive parameters from logs through `config.filter_parameters`. The default initializer already covers common patterns.

**Default configuration** (`config/initializers/filter_parameter_logging.rb`):

```ruby
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key, :crypt,
  :salt, :certificate, :otp, :ssn, :cvv, :cvc
]
```

Add any project-specific sensitive fields to this list:

```ruby
Rails.application.config.filter_parameters += [
  :date_of_birth, :tax_id, :bank_account, :iban,
  :medical_record, :social_security
]
```

The filter uses partial match. The pattern `:passw` matches `password`, `password_confirmation`, and `old_password`.

### Avoid manual exposure through Rails.logger

The most common mistake is to log model attributes or request parameters directly with `Rails.logger`.

❌ **Bad** — logs the full user object, which includes the email and password digest:

```ruby
Rails.logger.info("User signed up: #{user.attributes}")
```

✅ **Good** — logs only the fields you need:

```ruby
Rails.logger.info("User signed up: id=#{user.id}")
```

❌ **Bad** — logs the full params hash, which bypasses `filter_parameters`:

```ruby
Rails.logger.debug("Received params: #{params.to_unsafe_h}")
```

✅ **Good** — uses the filtered version:

```ruby
Rails.logger.debug("Received params: #{request.filtered_parameters}")
```

### Use ParameterFilter for custom log entries

When you write custom log entries outside the request cycle, use `ActiveSupport::ParameterFilter` to redact sensitive values.

❌ **Bad** — logs the raw API response with tokens:

```ruby
Rails.logger.info("API response: #{api_response.body}")
```

✅ **Good** — filters the response before the log call:

```ruby
filter = ActiveSupport::ParameterFilter.new(
  Rails.application.config.filter_parameters
)
safe_body = filter.filter(JSON.parse(api_response.body))
Rails.logger.info("API response: #{safe_body}")
```

### Filter redirect URLs

If your application redirects to URLs that contain tokens or other sensitive data, filter them:

```ruby
Rails.application.config.filter_redirect += [
  /token=/, /secret/, /oauth/
]
```

## Node.js backends

Node.js frameworks such as Next.js and Nest.js do not include a built-in log redaction mechanism, unlike Rails. Whatever the framework, the approach is the same: use a structured logger with redaction configured at startup, and never use `console.log` for application events.

Our preferred logger is [Pino](https://github.com/pinojs/pino), which supports redaction natively. If a project already uses [Winston](https://github.com/winstonjs/winston), configure redaction through a custom format as shown below.

### Set up Pino with redaction

Create a shared logger module and configure the `redact` option at startup. This applies to Next.js, Nest.js, Express, or any other Node.js framework:

```typescript
// lib/logger.ts
import pino from "pino";

const logger = pino({
  redact: {
    paths: [
      "password",
      "token",
      "accessToken",
      "refreshToken",
      "authorization",
      "cookie",
      "creditCard",
      "cvv",
      "ssn",
      "headers.authorization",
      "headers.cookie",
      "body.password",
      "body.token",
      "body.creditCard",
      "*.password",
      "*.secret",
      "*.apiKey",
    ],
    censor: "[REDACTED]",
  },
});

export default logger;
```

Import this logger everywhere. Do not use `console.log` for application events.

### Pino in Nest.js

In Nest.js, use [nestjs-pino](https://github.com/iamolegga/nestjs-pino) so the framework's `Logger` and the HTTP request logs go through Pino with the same redaction rules:

```typescript
// app.module.ts
import { Module } from "@nestjs/common";
import { LoggerModule } from "nestjs-pino";

@Module({
  imports: [
    LoggerModule.forRoot({
      pinoHttp: {
        redact: {
          paths: [
            "req.headers.authorization",
            "req.headers.cookie",
            "req.body.password",
            "req.body.token",
            "res.headers['set-cookie']",
            "*.password",
            "*.secret",
            "*.apiKey",
          ],
          censor: "[REDACTED]",
        },
      },
    }),
  ],
})
export class AppModule {}
```

Note that `pino-http` logs the full request object, so the paths must be prefixed with `req.` and `res.` to cover headers and bodies.

### Winston

Winston has no built-in redaction option. Add it with a custom format that filters sensitive keys before the entry is written:

```typescript
// lib/logger.ts
import winston from "winston";

const SENSITIVE_KEYS = [
  "password", "token", "accesstoken", "refreshtoken",
  "authorization", "cookie", "creditcard", "cvv",
  "ssn", "secret", "apikey",
];

const redact = winston.format((info) => {
  const filter = (value: unknown): unknown => {
    if (Array.isArray(value)) return value.map(filter);
    if (value && typeof value === "object") {
      return Object.fromEntries(
        Object.entries(value).map(([key, val]) =>
          SENSITIVE_KEYS.includes(key.toLowerCase())
            ? [key, "[REDACTED]"]
            : [key, filter(val)]
        )
      );
    }
    return value;
  };
  return filter(info) as winston.Logform.TransformableInfo;
});

const logger = winston.createLogger({
  format: winston.format.combine(redact(), winston.format.json()),
  transports: [new winston.transports.Console()],
});

export default logger;
```

The redact format must be the first format in the `combine` chain so it runs before serialization. Unlike Pino's path-based redaction, this recursive approach also catches sensitive keys at any nesting depth.

### Avoid raw request data in logs

The examples below use Next.js route handlers, but the same rules apply to Nest.js controllers and any other framework: redaction only covers structured fields, so never log raw request objects.

❌ **Bad** — logs the full request body, which can include passwords and tokens:

```typescript
export async function POST(req: NextRequest) {
  const body = await req.json();
  console.log("Request body:", body);
  // ...
}
```

✅ **Good** — logs only the fields you need, through the configured logger:

```typescript
import logger from "@/lib/logger";

export async function POST(req: NextRequest) {
  const body = await req.json();
  logger.info({ userId: body.userId, action: "login" }, "Login attempt");
  // ...
}
```

❌ **Bad** — logs all request headers, which include Authorization and cookies:

```typescript
console.log("Headers:", Object.fromEntries(req.headers));
```

✅ **Good** — logs only the headers you need:

```typescript
logger.info(
  { contentType: req.headers.get("content-type") },
  "Request received"
);
```

### Avoid sensitive context in error handlers

Error handlers and catch blocks often dump the full error context. This can include request data, user records, or API responses with tokens.

❌ **Bad** — logs the full error object and the payment data:

```typescript
try {
  await processPayment(paymentData);
} catch (error) {
  console.error("Payment failed:", { error, paymentData });
}
```

✅ **Good** — logs the error message and a safe identifier:

```typescript
try {
  await processPayment(paymentData);
} catch (error) {
  logger.error(
    { orderId: paymentData.orderId, error: (error as Error).message },
    "Payment failed"
  );
}
```

## References

- OWASP Logging Cheat Sheet: `https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html`
- OWASP Top 10 A09:2021: `https://owasp.org/Top10/A09_2021-Security_Logging_and_Monitoring_Failures/`
- GDPR Article 5 — data minimization: `https://gdpr-info.eu/art-5-gdpr/`
- Rails parameter filters: `https://guides.rubyonrails.org/configuring.html`
- Pino redaction: `https://github.com/pinojs/pino/blob/main/docs/redaction.md`
- nestjs-pino: `https://github.com/iamolegga/nestjs-pino`
- Winston custom formats: `https://github.com/winstonjs/winston#creating-custom-formats`
