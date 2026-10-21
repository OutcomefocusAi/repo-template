#!/usr/bin/env bash
# Fails when a hand-written file contains an em dash (U+2014).
# Checks tracked files plus untracked files that are not ignored.
# Generated and vendored files are excluded; see AGENTS.md (writing style).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

em_dash=$'\u2014'
if matches=$(git grep --untracked -n -I -F -e "$em_dash" -- . \
  ':(exclude,glob).agents/skills/openspec-*/**' \
  ':(exclude,glob).agents/skills/ponytail*/SKILL.md' \
  ':(exclude,glob).agents/skills/ponytail*/LICENSE' \
  ':(exclude,glob)**/LICENSE' \
  ':(exclude)CHANGELOG.md'); then
  echo "Em dash (U+2014) found in hand-written files. Use a comma, colon, parentheses, or a new sentence:" >&2
  echo "$matches" >&2
  exit 1
fi
echo "check-em-dash: no em dashes in hand-written files"
