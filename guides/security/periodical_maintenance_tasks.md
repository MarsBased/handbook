# Periodical Maintenance Tasks

Taking care of an application's security is not a one-off task, but an ongoing effort. Here is a reference of some tasks you should perform periodically (every few months) to ensure the application is not only built in a secure way but also kept always secure.

## Search the code for secrets

Make sure [no credentials have been introduced to the code](web_application_security_features.md#no-credentials-in-code-no-credentials-in-generated-artifacts). There are static analysis tools that can help detect leaked secrets. [trufflehog](https://github.com/trufflesecurity/trufflehog) is one such tool. It can be used in a Github Action, ran as a git commit hook, or just run manually from the command line.

## Search vulnerabilities

There are static analysis tools to automatically detect CVEs and other vulnerabilities in an application or built artifact.

[Snyk](https://snyk.io/) is one such tool. It is cross-platform and allows detecting vulnerabilities in several language runtimes, in Docker images, Infrastructure-as-Code definitions, and Open Source dependencies.

There are other platform-specific solutions that can also be very useful and complete the more generic scans.

### Rails

- [Brakeman](https://brakemanscanner.org/) can scan for several vulnerabilities on Rails projects. It can be used in a Github Action to run on every pull request, run as a git commit hook, or run manually on the demand from the command line.
- [Bundler-audit](https://github.com/rubysec/bundler-audit) can find vulnerable library versions and provide an upgrade path to a secure version.

### Next.js

- Enable dependency and runtime scanning in CI:
  - `npm audit`/`yarn npm audit` for quick checks.
  - [Dependabot](https://docs.github.com/en/code-security/dependabot) to monitor npm vulnerabilities and open upgrade PRs.
- Add static checks and secure config verifications:
  - Verify `next.config.js` has strict security headers (HSTS, `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`) and a CSP policy.
  - Validate `images.remotePatterns` is restricted to known hosts; avoid overly broad wildcards.
  - If using SVGs, confirm `dangerouslyAllowSVG` is truly needed and CSP for images is restrictive.
- Lint for dangerous patterns:
  - Disallow `dangerouslySetInnerHTML` without sanitization.
  - Flag dynamic `child_process` usage and `require()` with untrusted values in server code.
- Review authentication and session setup regularly:
  - Ensure cookies are `HttpOnly`, `Secure`, `SameSite=Lax` and rotated on login.
  - For Server Actions, set `serverActions.allowedOrigins` when behind proxies and keep `NEXT_SERVER_ACTIONS_ENCRYPTION_KEY` configured in self-hosted setups.

### Docker

- [Docker scout](https://docs.docker.com/scout/) can be used to detect CVEs in all the layers of a Docker image.

## Remove obsolete 3rd party integrations

It is important to revoke access to the code/data from an integration once it is no longer used. These may be:

- Error tracking tools (example: Sentry).
- Performance monitoring tools (example: New Relic, DataDog).
- User analytics tools (example: Google Analytics, Mixpanel).
- Code analysis tools (example: Code Climate).
- Continuous Integration tools (example: Circle CI).
- Project management tools (example: Linear).
- Repositories.

Once such a tool is no longer needed we should make sure to:

- Revoke API keys and/or users from the service.
- Remove the corresponding environment variables and - secrets if necessary.
- Remove libraries from the code, if necessary.
- Remove running processes, if necessary.

## Remove public access from S3 buckets

We often use AWS S3 to store files uploaded to a web application. We should make sure that these buckets have public access disabled and only allow public access when strictly necessary and only for files that don't contain any confidential or sensitive information.
When creating a new bucket, public access is disabled by default. Nevertheless, it's a good idea to check all existing buckets to make sure their configuration is correct, in case it has been changed.

When downloading files from S3, in general, we should do it from the back end. When doing so, no public access is needed because the back end will download the file from S3 using an authorization token.

ℹ️ Public access is only needed if we want users to download those files from an S3 URL directly without going through the server.

## Review users and permissions

Make sure that only people working currently on the project has access to 3rd party services. Remove any user that does not correspond to any of these people. These include:

- Remote repository (example: Github).
- Error tracking tools (example: Sentry)
- Monitoring tools (example: New Relic, DataDog).
- Analytics tools (example: Google Analytics, Mixpanel).
- Code analysis tools (example: Code Climate).
- Continuous Integration tools (example: Circle CI).
- Project management tools (example: Linear).
- Cloud provider (examples: AWS, Digital Ocean, Azure).
- Web application on production and pre-production environments.

Other key places to check:

- VPN: Revoke any unneeded VPN users or certificates.
- SSH keys: Remove any unneeded SSH keys from remote servers.
- 1password vault.

## Cloud provider

⚠️ The cloud provider deserves special attention because it allows direct access to the application infrastructure. Apart from making sure only people working on the project have access, we should review their permissions.

The majority of cloud providers have an IAM system that allows giving very specific permissions to each user. Make sure that each user has only the strictly necessary permissions to perform their work. This adds security to the project and peace of mind to the team members. For example:

- There should be just one or two admin users with complete control of the account.
- The tech lead should have complete permissions over all the services used by the application, and IAM permissions to be able to configure and modify users. But she should not have permission for billing, or services not used by the application.
- Most software engineers should have only the necessary permissions to deploy, view the deployment service (EKS, ECS, etc.), and view the logs.

⚠️ Another key point is adding only the strictly necessary permissions to users corresponding to the web application or 3rd party services.

Often an application will need to interact with the cloud provider. The most common example is when uploading files to an S3 bucket. Use policies with granular permissions to allow access only to the exact services and resources needed by the application. For example, if the application needs to upload files to S3 we would add a policy to the user with only the 3 or 4 permissions to upload and download files and limit those to only the bucket that has the files.

## Web application on production and pre-production environments

Make sure only people working on the project have access to the application (in any of its environments). This usually translates into checking the admin users on the application, but it may be other types of user accounts or access methods.
