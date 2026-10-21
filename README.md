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

4. Record the template version in `TEMPLATE_SOURCE.md`: under "Created from", fill in the template tag, its full commit SHA, and today's date. The SHA of a tag is printed by:

   ```bash
   gh api repos/OutcomefocusAi/repo-template/commits/<tag> --jq .sha
   ```

5. Open the first issue with the "OpenSpec change" form for the project proposal. That proposal picks the stack (defaults in `AGENTS.md`) and fills the CI slots (below).

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

- **This template repository** is public, where GitHub Free allows rulesets. Its `main` is protected by the ruleset `protect-main`, which blocks direct pushes, force pushes, deletion, and merges without a passing `template-checks`, `project`, and `qa-gate`, with no bypass for anyone.
- **Private repositories on GitHub Free for organizations** cannot use rulesets or branch protection. There the checks only flag violations: `qa-gate` shows a failed status until Principal QA ships the head, and `main-guard` marks a commit pushed to `main` without a pull request with a red status. Nothing stops the push or merge itself; the rule in `AGENTS.md` does.

## Actions minutes

Standard GitHub-hosted runners are free for public repositories. Private repositories use the organization's included minutes (2,000 a month on GitHub Free), so CI here is Linux-only with short timeouts.
