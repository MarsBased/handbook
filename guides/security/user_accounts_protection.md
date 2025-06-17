# User accounts protection

It is crucial to prevent user accounts from being hacked or stolen. There are some factors that the application can't control because they depend on the user using secure practices herself. But there are a few security measures an application can implement to reduce the risk to the minimum:

- Consider allowing users to enable Two-factor authentication. Depending on the sensitivity of the data managed by the application, consider making it mandatory. For example, a banking application should implement mandatory 2FA.
- Require strong and non-exploited passwords. The same rules that apply to your personal security should apply to your application users' passwords. Enforce these rules. It's also a good idea to check passwords against a [list of cracked passwords](https://haveibeenpwned.com/API/v3). In Ruby, you can use the [pwned gem](https://github.com/philnash/pwned) to do it in a very easy way.
- When changing the password: Force users to enter the current password and log users out after changing it.

## Prevent user enumeration attacks

A user enumeration attack consists of discovering the e-mails of registered users by exploiting a public page that inadvertently exposes such information.

This is commonly found in the sign-in, reset password, and sign-up pages. In order to prevent it, the page should always show the same error message when authentication fails. It does not matter if it failed because the e-mail does not exist, because the password is wrong, or because the account is blocked. The user should always receive the same error.

The same rule should be applied to the reset password page. Regardless of whether the introduced e-mail exists or not, we should return the same message to the user.

On the sign-up page it's more tricky to prevent because we need to let the user know if an e-mail address exists. For such pages, the recommended approach is to require solving a reCAPTCHA after a number of failed attempts.

## Prevent brute-forcing passwords

If an attacker knows or discovers the e-mail address of a registered user, she could use it to guess the password by making continuous login attempts.

In order to prevent such an attack, it's recommended to limit the number of failed login attempts. The limit can be applied per user account or per IP. After the limit is reached, the account/IP is blocked for a certain time. A common approach is to use exponential back-off to calculate this time. The first time an account is blocked it will be for 5 minutes, for instance, the second time 15 minutes, the third time 1 hour, etc.
