#!/usr/bin/env bash
# Bump opencode version and create/update a PR.
# Usage: scripts/bump-version.sh <upstream-version> <target-branch>
# Requires: curl, jq, gh, git
set -euo pipefail

VERSION="${1:?usage: bump-version.sh <upstream-version>}"
[ -z "$VERSION" ] && die "version must not be empty"
VERSION="${VERSION#v}"   # strip leading v if present
BRANCH="pr/opencode-release/v${VERSION}"
TARGET="${2:-main}"

log() { echo "[bump] $*"; }
die() { echo "[bump] error: $*" >&2; exit 1; }

# Check if an open PR already exists for this version
pr_exists() {
  local urls
  urls=$(gh pr list --state open --label "opencode-release" --json url -q '.[].url' \
    2>/dev/null)
  [ -n "$urls" ] && echo "$urls" | grep -qi "v${VERSION}"
}

create_pr() {
  local title="feat: opencode release v${VERSION}"
  local body="Automatic version bump for opencode ${VERSION}.\n\nChangelog:\nhttps://github.com/anomalyco/opencode/releases/tag/v${VERSION}\n\n> This PR was created automatically by a scheduled workflow."

  gh pr create \
    --title "$title" \
    --body "$body" \
    --base "$TARGET" \
    --label "opencode-release" \
    --label "automated"
}

update_pr() {
  local title="feat: opencode release v${VERSION}"
  local body="Automatic version bump for opencode ${VERSION}.\n\nChangelog:\nhttps://github.com/anomalyco/opencode/releases/tag/v${VERSION}\n\n> This PR was created automatically by a scheduled workflow."

  gh pr edit \
    --head "$BRANCH" \
    --title "$title" \
    --body "$body"
}

log "Checking for existing PR for v${VERSION}..."

git fetch origin "$BRANCH" 2>/dev/null && git checkout "$BRANCH" || git checkout -b "$BRANCH"

if pr_exists; then
  log "PR for v${VERSION} already exists, updating..."
  update_pr
else
  log "Creating new PR for v${VERSION}..."
  create_pr
fi

git checkout "${TARGET}" 2>/dev/null || true
