# Security related headers

The following headers protect the application against various attack types. Send them in all server responses unless the application you are working on has some specific needs:

- _X-Frame-Options: SAMEORIGIN_: Allow iframes only on the same domain. If you are also sending a Content Security Policy header it might not be necessary. In any case, it might still be a good idea to include it for legacy browsers that don't support CSP.
- _X-Content-Type-Options: nosniff_: Stops the browser from guessing the MIME type of a file.
- _X-Download-Options: noopen_: Instructs Internet Explorer not to open a download directly.
