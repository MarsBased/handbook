# Cookies best practices

Cookies are stored in the browser. They are used to persist some state across page requests. Most commonly we store the user session in cookies, but there could also be some settings for the page like the theme, or other pieces of data.

⚠️ Because cookies are stored in the browser, they are easily manipulated by the user.

Take these precautions when working with cookies:

- **Always add the Secure flag to cookies.** This instructs the browser to only send the cookies to the server when using an HTTPS connection. This avoids these cookies from being read by a third party sniffing the network.
- **Add HttpOnly flag when access from Javascript is not needed.** This instructs the browser to disallow Javascript to read the contents of the cookie.
- **Add the SameSite=Lax flag when possible.** This prevents some types of CSFR attacks and still allows cookies to be sent when users click on links.
- **Encrypt the session cookie.** The session cookie is the most sensitive cookie because it authenticates the user. By encrypting it we prevent it from being read even if a malicious party is able to access it.
- **Avoid storing sensitive data in cookies.** Use IDs of records stored in the database and fetch those records server-side.
- Similarly, - **don't rely only on data in the cookies.** Always validate it server-side or retrieve it from the database using an ID.
