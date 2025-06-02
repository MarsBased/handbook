# Common attack vectors

There are multiple ways a web application can be exploited. These are some of the most common attack vectors your application should be protected from:

## Protect against Cross-Site Scripting (XSS)

Cross-Site Scripting, most commonly known as XSS, is one of the most prominent attack methods on web applications.

It consists of injecting an arbitrary script on a page. When another user is browsing the page, it will execute the script. The script could do anything: modify the user cookies, trigger a request on the user's behalf, copy some sensitive data and send it elsewhere, redirect the user to another site, etc.

Any element on a page that renders user input data is susceptible to being vulnerable to XSS attacks.

### Mitigation

There is no single technique to protect against XSS. Protection is achieved by following some best practices:

- When showing plain text, HTML-escape all user input: replace the HTML input characters _&_, _"_, _<_, and _>_ by their uninterpreted representations in HTML (_\&amp;_, _\&quot_;, _\&lt;_, and _\&gt;_)

- When showing HTML, sanitize all user input: Use a white-listing technique to only allow a handful of safe HTML tags: _&lt;p&gt;_, _&lt;span&gt;_, _&lt;b&gt;_ , _&lt;i&gt;_, etc. And equally important: sanitize all attributes on these tags. Only allow a handful of safe attributes: _class_, _id_, etc. If you need to allow style attributes for example, make sure to properly sanitize them. They can be used to perform [CSS injection attacks](https://owasp.org/www-project-web-security-testing-guide/v41/4-Web_Application_Security_Testing/11-Client_Side_Testing/05-Testing_for_CSS_Injection).

- On the front-end, avoid rendering user input as HTML: avoid the usage of jQuery's _html()_ as much as possible. Use _text()_ instead. Similarly, avoid using _innerHTML =_  unless you are sure the content is properly sanitized.

- [Implement a strict Content Security Policy (CSP)](web_application_security_features.md#implement-a-strict-content-security-policy-csp)

⚠️ IMPORTANT: When sanitizing HTML avoid using a black-listing technique. It's impossible to list all possible tags that can be used for malicious purposes. An attacker will always know the one that you don't know about.

## Protect against SQL Injection

SQL injection is another common way of attacking a web application. It consists of exploiting a database query that interpolates user input data without sanitizing it. It gives an attacker the chance to execute any arbitrary query on the database.

ℹ️ SQL injection used to be a very popular attack methodology and pretty easy to exploit, especially in the PHP days. Fortunately, frameworks have matured a lot since then and it's now very difficult to find SQL injection vulnerabilities.

### Mitigation

Make sure to always sanitize user-inputted data before using it in a query. The specific details of how to do it depend on each database engine. However, you will rarely need to do this manually. Most ORM frameworks protect against SQL injection by default when used in the right way. Check each framework-specific documentation to learn how to build safe queries.

Another measure that can help lower the impact of an SQL injection attack, in the event of happening, is to restrict as much as possible the permissions of the database user being used by the application. Make sure the database user used by the web application has only the necessary permissions.

## Protect against Headers injection

When using the values of HTTP headers in your application, take into account that headers can be easily modified by an external party. Headers are just a part of an HTTP request and they can be changed in the same way as the query parameters or the body of the request can be changed.

A common case is an application that uses the value of the _Host_ header to render URLs on the page or in e-mails. Since the _Host_ header can be manipulated to contain a malicious hostname, the application might be including links to the malicious site.

Another less common but very dangerous scenario is when including a request parameter or other user-inputted data in a header. The user could introduce a carriage return to include any other malicious headers in the request or even two carriage returns to send an arbitrary response, hiding the real response from the server. [The Rails security guide](https://edgeguides.rubyonrails.org/security.html#header-injection) is a great resource to find more details on this type of attack.

### Mitigation

Always validate or sanitize the value of the headers before using them in a way that can be harmful to the application or the user.

Most web application frameworks include a set of default measures to prevent header injection attacks. But you still need to be diligent when modifying the value of response headers or including your own headers.

## Protect against Session Fixation

Session Fixation is a type of attack that only affects applications that store the user session in the database.

The common way to execute it is by exploiting an XSS vulnerability. The attacker injects a script that modifies the session ID stored in the cookies, by replacing it with the same session ID that the attacker is using.

This forces the user to log in again. When done so, both the user and the attacker will be logged in as the user because they are both using the same session ID.

### Mitigation

When storing sessions in the database, always reset the session after every login. This will generate a new ID and invalidate the malicious ID that the attacker injected.

### Implementation

#### Rails

Call the _reset_session_ method after login. When using [Devise](https://github.com/heartcombo/devise) this is done automatically.
