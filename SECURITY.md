# Security policy

## Reporting a vulnerability

Please do not open a public issue for a security problem. Report it privately through GitHub: on this repository's **Security** tab, choose **Report a vulnerability** (private vulnerability reporting). If that option is not shown, open an issue that says only "security contact requested", with no details, and the owner will reach out.

Expect an acknowledgement within 7 days.

## If a secret is exposed

1. **Revoke** the secret at its issuer first, so the leaked value stops working.
2. **Rotate**: issue a new secret and store it only in `.env`, the CI secret store, or the hosting provider's settings.
3. Remove the value from the code and record what happened in the related issue. Rewriting git history does not make a pushed secret safe; revocation does.

## Supported versions

Only the latest release of this repository is supported.
