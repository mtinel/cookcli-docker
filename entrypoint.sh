#!/usr/bin/env bash
set -euo pipefail

: "${BRANCH:=main}"
: "${SYNC_INTERVAL:=3600}"
REPO_DIR="/recipes"

git_clone() {
  if [ ! -d "$REPO_DIR/.git" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cloning git repository [$GIT_REPO] ..."
    local repo_url="${GIT_REPO}"
    [ -z "${REPO_TOKEN:-}"] || repo_url=$(echo "$GIT_REPO" | sed -E "s#https://#https://${REPO_TOKEN}@#")
    git clone --depth 1 --branch "$BRANCH" "$repo_url" "$REPO_DIR"
  fi
}

git_sync() {
  while true; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Synchronize git repository..."
    cd "$REPO_DIR"
    git fetch --all --prune
    git checkout "$BRANCH"
    git reset --hard "origin/$BRANCH"
    sleep "$SYNC_INTERVAL"
  done
}

[ -z "${GIT_REPO:-}" ] || (git_clone && git_sync &)

exec "$@"