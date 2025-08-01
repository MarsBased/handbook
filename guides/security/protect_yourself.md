# Protect Yourself

All accounts you use to work at MarsBased need to be protected appropriately. Examples include your MarsBased Slack account, the Sentry account for a client project, and your personal GitHub account if you use it to work on MarsBased projects.

A properly protected account:

- Has a [Strong password](#strong-password).
- Has [2FA](#two-factor-authentication) enabled for the services that allow for it.

Pay special attention to securing your email accounts.

## Strong password

There are different ways to create a strong password. Historically, the advice has been to use random passwords combining distinct character classes: lowercase letters, uppercase letters, numbers, and symbols.

However, more recent [research](https://arxiv.org/abs/1505.05090) and [advice](https://www.fbi.gov/contact-us/field-offices/portland/news/press-releases/oregon-fbi-tech-tuesday-building-a-digital-defense-with-passwords)  suggest that using a long passphrase containing real words is as good or even better.

In either case, the important rules to follow are:

- It **should be** at least 12 characters long. When using a passphrase it should be at least 15 characters long.
- It **should not** contain memorable keyboard paths like "qwerty".
- It **should not** include generic words like "password" or "12345".
- It **should not** include personal information that could be guessed by a bad actor.
- Passwords **should be** unique. Don't reuse the same password for different accounts.

Because it's impossible for almost everyone to memorize all their passwords, we recommend using a password manager to keep all your passwords securely stored. MarsBased provides you with a [1Password](https://1password.com/) account, but feel free to use a different tool if you feel more comfortable with them.

In any case:

- **Never write your passwords down in plain text in a digital or hand-written document.**
- **Never share your passwords with anyone in plain text, unless absolutely necessary.** If you need to share a password with a college, use a shared password vault (you can use 1Password). If you need to share it with a client and the client has no tool for it, you can always tell it by voice in a call.

ℹ️ _Additionally, you should change the password for the most sensitive accounts every 12 months: password manager, email accounts, slack, github, AWS and other PaaS/IaaS, etc._

## Two-factor authentication

ℹ️ _A secure account is one that requires something that you know (the password) with something that you have (the 2FA code). This way, even if someone discovers what you know (the password), they still need what you have to access your account._

You should enable 2FA for all services that support it. We recommend using [Authy](https://authy.com/). Authy uses TOTP codes as a 2FA mechanism and it's compatible with Google Authenticator.

A TOTP code is a 6-digit code that changes every few seconds. When logging in to a service with 2FA enabled, you will need to check the code for that particular service in the Authy app and enter it. TOTP codes are not reusable, so even if you log in again before the code has expired, it won't allow using the same code. This makes it impossible for a bad actor to do a request reply attack to gain access to your account.

Another popular option is to use 2FA by e-mail. It's the same idea but the code gets sent to your e-mail instead.

When you set up your 2FA you’ll be provided with a set of recovery codes. Store these recovery codes in your 1-password vault so you can recover them later while keeping them safe.

## Securing your email accounts

Email accounts are one of the most sensitive to protect. If someone got access to your email account they could:

- Impersonate yourself with potentially catastrophic consequences for MarsBased, clients and yourself.
- Reset your password on any service to gain access to it.
- Access 2FA protected services in case 2FA is used via e-mail.

Therefore make sure that for your e-mail accounts:

- You use a strong password, following the rules above.
- **You change the password at least every 12 months. Ideally every 6 months.**
- Enable a PIN or other sort of second step authentication for e-mail accounts.

Pay attention to any clue of unauthorized access to your e-mail account and take immediate action if you detect it. In such a case, you should also **immediately notify one of the MarsBased founders.** In such a scenario, auditing needs to be done to assess the damage.

## Phishing and email spoofing awareness

When accessing external services be aware of phishing. Check the URL before disclosing any sensitive information like your user and password.

Be aware also of email spoofing. If you receive a suspicious email from any of your colleagues or managers, double check with them that it’s a legitimate request before disclosing sensitive information.
