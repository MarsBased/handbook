# Admin panel protection

Most applications have an administration panel. The administration panel is the most sensitive part of an application because it usually allows performing all sorts of actions and modifications that regular users can't do.

It is critical to protect it properly:

- It is strongly recommended to make Two-factor authentication mandatory for all admin users.
- Consider hiding the admin panel behind a VPN. Only users connected to the VPN will be able to open the admin panel.
- Consider hosting the admin panel in a subdomain different from the public application domain. This alone prevents some forms of attack, like stealing the cookies from the public site to log in to the admin panel.
- Considering placing the admin panel in a hard-to-guess path different to /admin. And, of course, don't include any reference to it in the robots.txt or sitemap.xml files.
- Consider adding roles to users with different permission levels. If a user account gets compromised but only has limited permissions, the harm will be reduced.
