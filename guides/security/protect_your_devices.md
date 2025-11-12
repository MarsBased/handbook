# Protect Your Devices

Follow these simple rules to keep your devices secure:

- [Encrypt your hard drive and backups](#encrypt-your-hard-drive-and-backups).
- [Keep your devices up to date with the latest security updates](#keep-your-devices-up-to-date-with-the-latest-security-updates).
- [Never install pirated software or download pirate files](#never-install-pirated-software-or-download-pirated-files).
- [Use a good VPN when connecting to a shared Wi-Fi](#use-a-good-vpn-when-connecting-to-a-shared-wi-fi).
- [Protect your home Wi-Fi](#protect-your-home-wi-fi).
- [Delete code and files when you stop working for a client](#delete-code-and-files-when-you-stop-working-for-a-client).

## Encrypt your hard drive and backups

Encrypting the hard drive of your devices it's important in the event of them being stolen. Even if the device is protected with a password, if the hard drive is not encrypted a bad actor could just remove the hard drive from the device and read it.

The way to do this depends on the specific device:

### iPhone and other Apple handheld devices

Data encryption is enabled by default as long as you use a passcode to unlock the phone. Data encryption does not encrypt the full hard drive but encrypts all credentials and other sensitive information. Avoid keeping code and confidential documents on your phone as much as possible. If you need to download a confidential document to read it on the phone, make sure to delete it once you are done.

### Android devices

In most Android devices data encryption is enabled by default. You can check it by going to Settings -> Security -> Encryption.

### Mac OS

Mac OS includes the FileVault feature to encrypt the full hard drive. Make sure to have it enabled. You can check if it's enabled from Preferences -> Security & Privacy -> FileVault.

### Windows

You can turn on disk encryption by going to Settings -> Privacy & security -> Device encryption.

### Linux

In Linux, disk encryption is distribution-specific. You should consult the distribution documentation to learn how to do it.

Encrypting the hard drive is as important as encrypting computer backups. Otherwise, a bad actor that gains access to the backup will still be able to read everything. The way to encrypt a backup is specific to each software. Please consult the relevant documentation to learn how to do it.

## Keep your devices up to date with the latest security updates

Operating Systems periodically release security patches. Make sure to apply them as soon as they are available. Note that this does not include doing OS major version upgrades, as those have further implications. A major version upgrade is only necessary when the current version stops being maintained. In those cases, it won't receive security patches so it's important to upgrade to a newer version.

## Never install pirated software or download pirated files

This includes pirated software, movies, music, etc. If you need to use a paid software tool, ask MarsBased about the possibility of buying it.

More generally, only download software and content from trusted sources. For engineers, this includes system packages and libraries we add to applications.

## Use a good VPN when connecting to a shared Wi-Fi

⚠️ _When we connect to a Wi-Fi spot in a public space such as a cafe or co-working office with a shared Wi-fi network, we are opening the gate for a bad actor to read all data sent and received to our device._

In the majority of cases, public spaces don't take care of Wi-Fi security. Therefore, it's important to use a VPN that encrypts all sent and received traffic. In some rare cases, the space may provide individual Wi-Fi networks to each person. In those cases, you shouldn't need any extra layer of security.

It's true that most traffic is sent and received using a secure protocol like HTTPS, and therefore it's protected from bad actors reading the traffic. However, there may still be applications or unsecure websites that send and receive unencrypted traffic.

The best way to be safe in every situation is to use a VPN. A VPN creates a secure tunnel between your device and the VPN servers and encrypts all traffic that flows through it. However, you should make sure to use a quality VPN. Some VPNs might not encrypt the traffic or might sell data to 3rd parties.

MarsBased has a [Private Internet Access](https://www.privateinternetaccess.com/buy-vpn-online) account you can use. You will find the credentials in 1password. Their app is available for different platforms. You can download it from the website.

## Protect your home Wi-Fi

Your home Wi-Fi should also be as secure as possible. Make sure it has a strong password.

## Delete code and files when you stop working for a client

The best way to reduce the risk of a bad actor getting access to confidential data is to not have the data at all!

A couple of months after stopping working on a project you should delete its code and all files associated with the project.

In some situations, it might be useful to consult the code for a project you have previously worked with. In order to keep this possibility open we recommend a couple of approaches:

1. Store only some files that contain some especially interesting code that you already know might be useful in the future.
1. When needed, ask for a colleague working on the project to temporarily share some specific pieces of code with you.
