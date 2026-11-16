#!/usr/bin/env bash
# Fails unless the OpenSpec-generated skill files in this checkout are exactly what the
# OpenSpec version pinned in .github/workflows/ci.yml generates:
#   .agents/skills/.openspec-target and every file under .agents/skills/openspec-*/
# The reference comes from `openspec init --tools agents --profile core` run in a temporary
# directory with a temporary OpenSpec config, so this checkout and the user's global OpenSpec
# config are never written. Content, git mode and file type are compared: each edited, missing,
# extra or untracked file, symlink, or file with another mode gets its own ::error annotation
# with the fix.
# Usage: scripts/check-openspec-skills.sh
#   OPENSPEC_CMD overrides the CLI (default: openspec), for example
#   OPENSPEC_CMD="npx -y @fission-ai/openspec@<pin>". It must report the pinned version.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
shopt -s nullglob

fail=0
err() { echo "::error file=$1,line=$2::$3"; fail=1; }
ci=.github/workflows/ci.yml

# 1. The pinned version: the single exact version in the @fission-ai/openspec@ install line.
pin=""; pin_line=1
hits=$(grep -n '@fission-ai/openspec@' "$ci" 2>/dev/null || true)
if [ -z "$hits" ]; then
  err "$ci" 1 "no @fission-ai/openspec@<version> install line found; the generated-skills check takes its version from that pin and never from latest"
else
  while IFS= read -r hit; do
    v=$(sed -E 's/.*@fission-ai\/openspec@([^[:space:]]*).*/\1/' <<<"$hit")
    if [[ ! "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      err "$ci" "${hit%%:*}" "OpenSpec pin '$v' is not an exact MAJOR.MINOR.PATCH version"
    elif [ -z "$pin" ]; then pin=$v; pin_line=${hit%%:*}
    elif [ "$v" != "$pin" ]; then
      err "$ci" "${hit%%:*}" "OpenSpec pin '$v' disagrees with '$pin' on line $pin_line"
    fi
  done <<<"$hits"
fi
[ "$fail" -eq 0 ] || exit 1

# 2. The CLI must be the pinned version.
read -r -a cmd <<<"${OPENSPEC_CMD:-openspec}"
fixcli="install it with 'npm install --global @fission-ai/openspec@$pin', or set OPENSPEC_CMD=\"npx -y @fission-ai/openspec@$pin\""
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
run_openspec() { env XDG_CONFIG_HOME="$tmp/xdg" XDG_DATA_HOME="$tmp/data" OPENSPEC_TELEMETRY=0 OPENSPEC_NO_UPDATE_CHECK=1 "${cmd[@]}" "$@"; }
if ! command -v "${cmd[0]}" >/dev/null 2>&1; then
  err "$ci" "$pin_line" "OpenSpec CLI '${cmd[*]}' not found; $fixcli"; exit 1
fi
have=$( (cd "$tmp" && run_openspec --version) 2>/dev/null | tail -n1 | tr -d '[:space:]' || true)
if [ "$have" != "$pin" ]; then
  err "$ci" "$pin_line" "OpenSpec CLI '${cmd[*]}' reports version '$have' but $ci pins '$pin'; $fixcli"; exit 1
fi

# 3. The reference, generated outside the checkout.
mkdir "$tmp/ref"
if ! (cd "$tmp/ref" && git init -q && run_openspec init --tools agents --profile core) >"$tmp/init.log" 2>&1; then
  err "$ci" "$pin_line" "'${cmd[*]} init --tools agents --profile core' failed in a temporary directory"; sed 's/^/  /' "$tmp/init.log"; exit 1
fi
list() { # print the generated-skill files under the current directory, sorted
  local p
  for p in .agents/skills/.openspec-target .agents/skills/openspec-*; do
    if [ -d "$p" ] && [ ! -L "$p" ]; then find "$p" \( -type f -o -type l \) -print; elif [ -e "$p" ] || [ -L "$p" ]; then echo "$p"; fi
  done | LC_ALL=C sort
}
(cd "$tmp/ref" && list) >"$tmp/ref.txt"
list >"$tmp/work.txt"
git ls-files --others -- .agents/skills | LC_ALL=C sort >"$tmp/untracked.txt"
git -c core.quotePath=false ls-files -s -- .agents/skills >"$tmp/index.txt"
total=$(grep -c . "$tmp/ref.txt" || true)
if [ "$total" -eq 0 ]; then
  err "$ci" "$pin_line" "'${cmd[*]} init --tools agents --profile core' generated no skill files"; exit 1
fi

# 4. Compare.
up="npx -y @fission-ai/openspec@$pin"
untracked() { grep -qxF -- "$1" "$tmp/untracked.txt"; }
fsmode() { # git mode of a path from the file system: 120000 symlink, 100755 executable, else 100644
  if [ -L "$1" ]; then echo 120000; elif [ -x "$1" ]; then echo 100755; else echo 100644; fi
}
mode_of() { # git mode of a checkout path: the index mode if tracked, else the file system's; a symlink is always 120000
  local m
  m=$(awk -v f="$1" '{ t = index($0, "\t"); if (substr($0, t + 1) == f) { print $1; exit } }' "$tmp/index.txt")
  if [ -L "$1" ] || [ -z "$m" ]; then fsmode "$1"; else echo "$m"; fi
}
drift=0
while IFS= read -r f; do
  drift=$((drift + 1))
  err "$f" 1 "missing: OpenSpec $pin generates this file but it is not in the checkout. Fix: run '$up init --tools agents --profile core' and commit the result, or restore it with 'git checkout -- $f'"
done < <(LC_ALL=C comm -23 "$tmp/ref.txt" "$tmp/work.txt")
while IFS= read -r f; do
  drift=$((drift + 1))
  if untracked "$f"; then
    err "$f" 1 "untracked: OpenSpec $pin does not generate this file and it is not committed. Fix: delete it, or keep a custom skill under a name that does not start with 'openspec-'"
  else
    err "$f" 1 "extra: OpenSpec $pin does not generate this file. Fix: delete it, or keep a custom skill under a name that does not start with 'openspec-'"
  fi
done < <(LC_ALL=C comm -13 "$tmp/ref.txt" "$tmp/work.txt")
while IFS= read -r f; do
  want=$(fsmode "$tmp/ref/$f"); have=$(mode_of "$f")
  if [ "$have" != "$want" ] && [ "$have" = 120000 ]; then
    drift=$((drift + 1))
    err "$f" 1 "symlink: is a symbolic link (git mode 120000) but OpenSpec $pin generates a regular file (git mode $want). Fix: delete the link, run '$up init --tools agents --profile core' and commit the regular file"
  elif [ "$have" != "$want" ]; then
    drift=$((drift + 1))
    x=-x; [ "$want" != 100755 ] || x=+x
    if untracked "$f"; then fixmode="run 'chmod $x $f' and commit it with 'git add -- $f'"
    else fixmode="run 'git update-index --chmod=$x -- $f' and 'chmod $x $f', and commit"; fi
    err "$f" 1 "mode: git mode $have but OpenSpec $pin generates $want. Fix: $fixmode"
  elif ! cmp -s -- "$tmp/ref/$f" "$f"; then
    drift=$((drift + 1))
    err "$f" 1 "edited: differs from what OpenSpec $pin generates. Fix: run '$up update' and commit the result, or revert the hand edit with 'git checkout -- $f'"
  elif untracked "$f"; then
    drift=$((drift + 1))
    err "$f" 1 "untracked: matches OpenSpec $pin but is not committed, so CI would see it as missing. Fix: commit it with 'git add -- $f'"
  fi
done < <(LC_ALL=C comm -12 "$tmp/ref.txt" "$tmp/work.txt")

if [ "$fail" -ne 0 ]; then
  echo "check-openspec-skills: $drift file(s) drifted from what OpenSpec $pin generates ($total generated file(s) expected)"
  exit 1
fi
echo "check-openspec-skills: $total generated file(s) match OpenSpec $pin"
