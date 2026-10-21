# preview-deploys Specification

## Purpose

Lets a derived project get Netlify Deploy Previews for review while making production publishing impossible through this configuration.

## Requirements

### Requirement: Production builds are refused
`netlify.toml` SHALL make any build in the production context stop without publishing, using two independent guards: an `ignore` command that skips production, and a production-context build command that exits non-zero.

#### Scenario: Push to the production branch
- **WHEN** Netlify builds the production branch of a linked site using this file
- **THEN** no new production deploy is published

### Requirement: Previews still build
`netlify.toml` SHALL let Deploy Previews and branch deploys build with the project's build command and publish directory, both marked as slots.

#### Scenario: Pull request opened on a linked site
- **WHEN** a pull request is opened on a repository linked to a Netlify site
- **THEN** a Deploy Preview builds using the slot commands

### Requirement: No secrets in netlify.toml
`netlify.toml` SHALL contain no credentials or sensitive values; any environment values SHALL be set in the Netlify UI.

#### Scenario: Secrets scan
- **WHEN** gitleaks scans `netlify.toml`
- **THEN** it finds nothing
