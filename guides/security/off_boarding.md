# Off-Boarding

When a team member stops working on a project and when we stop working with a client altogether we should take some clean-up steps. This is important to make sure we no longer have access to the client's code and data.

## Martian off-boarding

When off-boarding a martian from a project we should:

- Remove all the user accounts from services used in the client's projects (Sentry, NewRelic, etc.). A good source to identify them is the client 1password vault.
- Remove the user from the Github repository.
- Remove the user from the 1password vault.

## Client off-boarding

When off-boarding a client we should make sure to:

- Remove all the service accounts owned by MarsBased (Sentry, NewRelic, etc.). A good source to identify them is the client 1password vault.
- Remove all martian accounts from services owned by the client.
- Review all items in the client 1password vault. For each of the items, think if some other actions are required (remove an account, remove a certificate from a server, etc.)
- Remove the client 1password vault.
