#!/usr/bin/env bash
# Checks that every non-merge commit in BASE..HEAD is a Conventional Commit
# ending in an issue reference such as "(#12)" (AGENTS.md, Traceability).
# Dependabot and release-please branches only need the Conventional Commit format.
# Usage: scripts/check-commits.sh BASE HEAD [HEAD_BRANCH]
set -euo pipefail
base=${1:?usage: check-commits.sh BASE HEAD [HEAD_BRANCH]}
head=${2:?usage: check-commits.sh BASE HEAD [HEAD_BRANCH]}
branch=${3:-$(git rev-parse --abbrev-ref HEAD)}

types='feat|fix|docs|chore|refactor|test|ci|build|perf|style|revert'
format="^(${types})(\\([^)]+\\))?!?: .+"
case "$branch" in
  dependabot/*|release-please--*) need_issue=0 ;;
  *) need_issue=1 ;;
esac

fail=0; count=0
while IFS=$'\t' read -r sha subject; do
  [ -n "$sha" ] || continue
  count=$((count + 1))
  if ! grep -Eq "$format" <<<"$subject"; then
    echo "::error::commit ${sha:0:12} is not a Conventional Commit: $subject"; fail=1; continue
  fi
  if [ "$need_issue" -eq 1 ] && ! grep -Eq '\(#[0-9]+\)$' <<<"$subject"; then
    echo "::error::commit ${sha:0:12} does not end with an issue reference like (#12): $subject"; fail=1
  fi
done < <(git log --no-merges --format='%H%x09%s' "${base}..${head}")

if [ "$fail" -ne 0 ]; then exit 1; fi
echo "check-commits: ${count} commit(s) pass on ${branch}"
