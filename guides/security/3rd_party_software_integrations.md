# 3rd Party Software Integrations

We should regularly review integrations with 3rd party software and remove any unneeded services or integrations. In particular:

- **Slack integrations**: Any Slack integration that is not needed anymore should be removed. This is particularly important for integrations with client projects. It is common to have error tracking or monitoring tools send alerts to a MarsBased Slack channel. When we stop working with a client or using a tool we should remove the corresponding integrations.
- **Github integrations**: Similarly we might have Github integrations. A typical example is an integration with Netlify or Render to be able to deploy automatically from GitHub pull requests. Sometimes client projects are hosted in repositories in the MarsBased GitHub account. It is especially important to keep those clean because the client has no control over them.
- **Linear integrations**: We usually connect Linear boards with GitHub or a similar service. Since Linear is a tool we used at the MarsBased level we should disconnect it once we stop working with a client or stop using the service. If we add additional integrations to Linear we should keep them clean in the same way.
