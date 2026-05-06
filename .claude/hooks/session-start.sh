#!/bin/bash
set -euo pipefail

# Only run in remote (Claude Code on the web) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

echo '{"async": true, "asyncTimeout": 300000}'

cd "$CLAUDE_PROJECT_DIR"

# Install cargo-binstall if not present
if ! command -v cargo-binstall &>/dev/null; then
  echo "Installing cargo-binstall..."
  cargo install cargo-binstall@1.14.3 --locked
fi

# Install cargo-nextest (test runner) if not present
if ! command -v cargo-nextest &>/dev/null; then
  echo "Installing cargo-nextest..."
  cargo binstall --secure --no-confirm --no-discover-github-token cargo-nextest
fi

# Install wgslfmt (WGSL shader formatter) if not present
if ! command -v wgslfmt &>/dev/null; then
  echo "Installing wgslfmt..."
  cargo install --git https://github.com/wgsl-analyzer/wgsl-analyzer --tag "2025-06-28" wgslfmt
fi

echo "Session start hook complete."
