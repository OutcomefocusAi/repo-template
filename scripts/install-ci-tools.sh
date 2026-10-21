#!/usr/bin/env bash
# Downloads the pinned gitleaks and actionlint release binaries, verifies each
# archive against a pinned SHA-256, and installs them into DEST (default:
# $RUNNER_TEMP/bin, or ./.ci-tools/bin locally). Refuses to install on mismatch.
# Pins are recorded in TEMPLATE_SOURCE.md; Dependabot does not update these,
# so bump version and checksum together by hand.
set -euo pipefail

GITLEAKS_VERSION=8.30.1
GITLEAKS_SHA256=${GITLEAKS_SHA256:-551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb}
ACTIONLINT_VERSION=1.7.12
ACTIONLINT_SHA256=${ACTIONLINT_SHA256:-8aca8db96f1b94770f1b0d72b6dddcb1ebb8123cb3712530b08cc387b349a3d8}

dest=${1:-${RUNNER_TEMP:-$PWD/.ci-tools}/bin}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$dest"

fetch() { # name url sha256 binary
  local name=$1 url=$2 sum=$3 bin=$4 archive
  archive="$work/$name.tar.gz"
  curl -fsSL --retry 3 -o "$archive" "$url"
  if ! echo "$sum  $archive" | sha256sum -c --status; then
    echo "::error::checksum mismatch for $name ($url); refusing to install" >&2
    exit 1
  fi
  tar -xzf "$archive" -C "$work" "$bin"
  install -m 0755 "$work/$bin" "$dest/$bin"
  echo "installed $name to $dest/$bin (sha256 verified)"
}

fetch gitleaks \
  "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" \
  "$GITLEAKS_SHA256" gitleaks
fetch actionlint \
  "https://github.com/rhysd/actionlint/releases/download/v${ACTIONLINT_VERSION}/actionlint_${ACTIONLINT_VERSION}_linux_amd64.tar.gz" \
  "$ACTIONLINT_SHA256" actionlint

if [ -n "${GITHUB_PATH:-}" ]; then echo "$dest" >> "$GITHUB_PATH"; fi
