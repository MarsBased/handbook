TODO: Add Emoji to make it more visual? add images?

# Personal Security Guide

Good security practices start on yourself and your own devices (laptop, mobile phone, etc.). Any device you use to do MarsBased work needs to be properly protected to minimize the chances of a bad actor accessing the device data.

## Protect your user accounts

All accounts you use to work at MarsBased needs to be properly protected. Examples include your MarsBased Slack account, the Sentry account for a client project or your personal GitHub account if you use it to work on MarsBased projects.

A properly protected account:
* Has a strong password.
* Has 2FA enabled if the service allows it.

### Strong password

There are different ways to create a strong password. Historically, the advice has been to use random passwords consisting of different character classes: lowercase letters, uppercase letters, number and symbols.

However, more recent [research](https://arxiv.org/abs/1505.05090) and [advice](https://www.fbi.gov/contact-us/field-offices/portland/news/press-releases/oregon-fbi-tech-tuesday-building-a-digital-defense-with-passwords) suggests that using a long passphrase containing real words is as good or even better.

In either case, the important rules to follow are:
* It should be at least 12 characters long. When using a passphrase it should be at least 15 characters long.
* It should not contain memorable keyboard paths like "qwerty".
* It should not include generic words like "password" or "12345".
* It does not include personal information that could be guessed by a bad actor.
* Passwords should be unique. Don't reuse the same password for different accounts.

Because it's impossible for almost everyone to memorize all their passwords, we recommend using a password manager to keep all your passwords securely stored. MarsBased provides you with a [1password](https://1password.com/) account, but feel free to use a different tool if you feel more comfortable with them.

In any case:
* **Never write your passwords down in plain text in a digital or hand-written document.**
* **Never share your passwords with anyone in plain text, unless absolutely necessary.** If you need to share a password with a college, use a shared password vault. If you need to share it with a client and the client has no tool for it, you can always tell it by voice in a call.

### Two-factor authentication

A secure account is one that requires something that you know (the password) with something that you have (the 2FA code). This way, even if someone discovers what you know (the password), they still need what you have to access your account.

For this reason, you should enable 2FA for all services that support it. We recommend using [Authy](https://authy.com/). Authy uses TOTP codes as a 2FA mechanism and it's compatible with Google Authenticator.

A TOTP code is a 6 digit code that changes every few seconds. When logging in a service with 2FA enabled, you will need to check the code for that particular service in the Authy app and enter it. TOTP codes are not reusable, so even if you log in again before the code has expired, it won't allow to use the same code. This makes it impossible for a bad actor to do a request reply attack to gain access to your account.

Another popular option is to use 2FA by e-mail. It's the same idea but the code gets sent to your e-mail instead.

## Protect your devices

Follow these simple rules to keep your devices secure:

### Encrypt your hard drive and backups

Encrypting the hard drive of your devices it's important in the event of it being stolen. Even if the device is protected with a password, if the hard drive is not encrypted a bad actor could just remove the hard drive from the device and read it.

The way to do this depends on the specific device:
* iPhone and other Apple handheld devices: Data encryption is enabled by default as long as you use a passcode to unlock the phone. Data encryption does not encrypt the full hard drive but encrypts all credentials and other sensitive information. Due to this, avoid as much as possible having code and confidential documents in the phone. If you need to download a confidential document to read it on the phone, make sure to delete it once you are done.
* Android devices: In most Android devices data encryption is enabled by default too. You can check it by going to Settings -> Security -> Encryption.
* Mac OS: Mac OS includes the FileVault feature to encrypt the full hard drive. Make sure to have it enabled. You can check if it's enabled from Preferences -> Security & Privacy -> FileVault.
* Windows: You can turn on disk encryption by going to Settings -> Privacy & security -> Device encryption.
* Linux: In Linux, disk encryption is distribution-specific. You should consult the distribution documentation to learn how to do it.

Encrypting the hard drive is as important as encrypting computer backups. Otherwise, a bad actor that gains access to the backup will still be able to read everything. The way to encrypt a backup is specific to each software. Please consult the relevant documentation to learn how to do it.

### Keep your devices up to date with the latest security updates

Operating Systems periodically release security patches. Make sure to apply them as soon as they are available. Note that this does not include doing OS major version upgrades, as those have further implications. A major version upgrade is only necessary when the current version stops being maintained. In those cases, it won't receive security patches so it's important to upgrade to a newer version.

### Never install pirate software or download pirate files

This includes pirate software, movies, music, etc. If you need to use a paid software tool, ask MarsBased for the possibility of buying it.

More generally, only download software and content from trusted sources. For developers, this includes system packages and libraries we add to applications.

### Use a good VPN when connecting to a shared Wi-Fi

When we connect to a Wi-Fi in a public space such as a cafe or co-working office with a shared Wi-fi network, we are opening the gate for a bad actor to read all data sent and received to our device.

In the majority of cases, these public spaces don't take care of the Wi-Fi security. In those cases, it's important to use a VPN that encrypts all traffic sent and received. In some rare cases, the space may provide individual Wi-Fi networks to each person. In those cases, you shouldn't need any extra layer of security.

It's true that most traffic is sent and received using a secure protocol like HTTPS, and therefore it's protected from bad actors reading the traffic. However, there may still be applications or unsecure websites that send and receive unencrypted traffic.

The best way to be safe in every situation is to use a VPN. a VPN creates a secure tunnel between your device and the VPN servers and encrypts all traffic that flows through it. However, you should make sure to use a quality VPN. Some VPNs might not encrypt the traffic or might sell data to 3rd parties.

MarsBased has a [Private Internet Access](https://www.privateinternetaccess.com/buy-vpn-online) account you can use. You will find the credentials in 1password. Their app is available for different platforms. You can download it from the website.

### Protect your home Wi-Fi

Your home Wi-Fi should also be as secure as possible. Make sure it has a strong password.

### Delete code and files when you stop working for a client

The best way to reduce the risk of a bad actor getting access to confidential data is to not have the data at all.

Therefore, a couple of months after stop working in a project you should delete its code and all files associated with the project.

However, in some situations it might be useful to consult the code for a project you have previously worked with. In order to keep this possibility open we recommend a couple of approaches:
1. Store only some files that contain some specially interesting code that you already know might be useful in the future.
1. When needed, ask for a college working on the project to temporarily share some specific pieces of code with you.
