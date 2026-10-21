#!/usr/bin/env bash
# Placeholder for a stack-specific CI step (lint, typecheck, test, coverage, build).
# In the template repository an unfilled slot passes with a warning. In any
# repository created from the template it fails until the first project
# proposal replaces the step with the stack's real command.
# Usage: scripts/slot.sh NAME
set -euo pipefail
name=${1:?usage: slot.sh NAME}
template_repo="OutcomefocusAi/repo-template"

if [ "${GITHUB_REPOSITORY:-}" = "$template_repo" ]; then
  echo "::warning title=Unfilled CI slot::'${name}' is a template slot. Derived repositories must replace it in their first project proposal."
  exit 0
fi
echo "::error title=Unfilled CI slot::'${name}' has no command yet. Fill this slot in .github/workflows/ci.yml through the repository's first project proposal (see README, Starting a new repository)."
exit 1
