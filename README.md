# repo-template

Language-neutral starter for new OutcomefocusAi repositories. It carries the working rules (`AGENTS.md`), the OpenSpec workflow, hardened CI with marked stack slots, secrets scanning, Dependabot, release-please, issue and pull request templates, and a preview-only Netlify configuration.

Rules for agents live in [`AGENTS.md`](AGENTS.md). Pinned tool versions and sources are in [`TEMPLATE_SOURCE.md`](TEMPLATE_SOURCE.md).

## Start a new repository

Replace `<name>` with the new repository name and `<tag>` with the template release to use (for example `v0.1.0`).

1. Create a private repository from the template and clone it:

   ```bash
   gh repo create OutcomefocusAi/<name> --private --template OutcomefocusAi/repo-template --clone
   cd <name>
   ```

2. Set the owner's commit identity for this clone:

   ```bash
   git config user.name "AgileKnow23"
   git config user.email "204773855+AgileKnow23@users.noreply.github.com"
   ```

3. Enable the secrets pre-commit hook (needs the `gitleaks` binary, version in `TEMPLATE_SOURCE.md`):

   ```bash
   git config core.hooksPath .githooks
   ```

4. Reset the release state copied from the template, so this repository's first release is `0.1.0` (the template's `CHANGELOG.md` and version belong to the template; `release-please-config.json` stays as it is):

   ```bash
   printf '{\n  ".": "0.0.0"\n}\n' > .release-please-manifest.json
   echo 0.0.0 > version.txt
   rm -f CHANGELOG.md
   ```

5. Record the template version in `TEMPLATE_SOURCE.md`: under "Created from", fill in the template tag, its full commit SHA, and today's date. The SHA of a tag is printed by:

   ```bash
   gh api repos/OutcomefocusAi/repo-template/commits/<tag> --jq .sha
   ```

6. Open the first issue with the "OpenSpec change" form for the project proposal. That proposal picks the stack (defaults in `AGENTS.md`) and fills the CI slots (below).

If you reuse the template outside OutcomefocusAi, edit the owner line in `AGENTS.md` section 1 and `.github/CODEOWNERS`.

## Fill the CI slots

`.github/workflows/ci.yml` has a `project` job whose steps are marked `# SLOT(<name>)`: lint, typecheck, test, coverage, and build. Each slot runs `scripts/slot.sh <name>`, which only warns in this template and fails in any other repository, so an unfilled slot cannot pass silently. The first project proposal replaces every slot with the real command (coverage fails below 80% line coverage on new code and below 90% on money and critical paths). `netlify.toml` and `.github/dependabot.yml` have slots of the same kind.

## Check for template drift

Template-managed paths are listed in `template-manifest.txt`. To see which of them differ from a template release (changes nothing):

```bash
scripts/template-drift.sh <tag>
```

It exits 0 when nothing differs and 1 when something does. Run it before each new project proposal. `.github/workflows/ci.yml` always shows as differing once its slots are filled; compare it by eye (`git diff --no-index`) and treat only changes outside the `SLOT` steps as drift.

## How main is protected

- **This template repository** is public, where GitHub Free allows rulesets. The ruleset `protect-main` blocks direct pushes, force pushes, deletion, and merges without a passing `template-checks`, `project`, and `qa-gate`, and it lists no bypass actors. All three checks are pinned to the GitHub Actions app, so a status posted directly through the API does not count. Extra approval for unattributed changes is off, so bot pull requests are not held. GitHub secret scanning, push protection, and private vulnerability reporting are on. Derived repositories need these settings applied themselves; a template does not copy them.
- **Private repositories on GitHub Free for organizations** cannot use rulesets or branch protection. There the checks only flag violations: `qa-gate` shows a failed status until Principal QA ships the head, and `main-guard` marks a commit pushed to `main` without a pull request with a red status. Nothing stops the push or merge itself; the rule in `AGENTS.md` does.
- **Limits in both:** all agents share the `AgileKnow23` login and token. Any of them can post a SHIP verdict that `qa-gate` accepts, any holder of the token can edit the ruleset (or, in a private repository, set the `qa-gate` status directly), and a pull request that edits `.github/workflows/` runs its own copy of `qa-gate`. The checks protect against mistakes and outsiders, not against the shared identity; the `AGENTS.md` rules (only Principal QA posts verdicts, the owner OKs every merge) are what hold.
- **Release pull requests** are opened by release-please with the built-in token, which works only when "Allow GitHub Actions to create and approve pull requests" is on for the organization and the repository. For this template both are on (issue #3), so each push to `main` runs `release`, which opens or updates the release pull request when there are releasable commits (with none, the run skips it); no tag or release is made until that pull request is merged. Its checks start only after someone clicks "Approve workflows to run" on the pull request, and it stays blocked until then. A derived repository needs the same setting turned on by an organization owner (Settings, Actions, General, Workflow permissions) and then in its own Actions settings; until then each push to `main` shows a failed `release` run ("GitHub Actions is not permitted to create or approve pull requests").

## Actions minutes

Standard GitHub-hosted runners are free for public repositories. Private repositories use the organization's included minutes (2,000 a month on GitHub Free), so CI here is Linux-only with short timeouts.
