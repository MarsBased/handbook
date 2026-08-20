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

## Next.js with Pino

Next.js does not include a built-in log redaction mechanism. Use [Pino](https://github.com/pinojs/pino) as the structured logger and configure its `redact` option to remove sensitive fields.

### Set up Pino with redaction

Create a shared logger module and configure redaction at startup:

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

### Avoid raw request data in logs

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
