# Operator Disclosure

This change deliberately introduces no convenient general GitHub client. A
live run requires a newly materialized exact provider authorization and a
single repository-scoped fine-grained PAT supplied over an inherited file
descriptor. The operator must not paste the token into chat, command arguments,
environment variables, a file, `gh`, a browser automation field, or Git remote.

If the provider outcome or credential terminal state is uncertain, the safe
result is a durable blocked state. The system will not retry, replace the token,
or call a UI action merely to finish the migration.
