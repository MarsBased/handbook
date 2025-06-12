# Securing backups

Backups are a point of failure that it's often not taken into account. Securing backups properly is crucial to avoid a malicious actor getting access to confidential data.

The personal security section already described how to secure personal computer backups. The points below refer to securing application data backups.

The most important consideration is that backups are kept safe. The specific details on how to do this depend on how backups are being managed.

In most cases, backups are taken care of by a 3rd party service. When using a managed database with AWS RDS or an equivalent service, backups are managed by AWS and kept in secure storage.
When backups are managed using a custom solution make sure the hard drive where they are stored is disconnected from the internet or has proper security rules to avoid unauthorized access.

Backups containing sensitive information must be encrypted.

ℹ️ When backing up encrypted data, make sure the backup is also encrypted. Apply the same security practices to encryption keys used to encrypt the data than to encrypt the backup.

