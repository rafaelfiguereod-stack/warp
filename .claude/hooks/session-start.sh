#!/bin/bash
set -euo pipefail

# Only run in remote (Claude Code on the web) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

echo '{"async": true, "asyncTimeout": 300000}'
# Route all subsequent output to stderr so stdout stays a clean async descriptor
exec 1>&2

cd "${CLAUDE_PROJECT_DIR:?CLAUDE_PROJECT_DIR is not set}"

# Attempt install; warn and continue on failure so a transient error doesn't
# kill the async hook and leave the session in a confusing broken state.
install_step() {
  local name="$1"; shift
  if command -v "$name" &>/dev/null; then return 0; fi
  echo "Installing $name..."
  if "$@"; then
    echo "Installed $name."
  else
    echo "WARNING: failed to install $name; skipping."
  fi
}

# Install cargo-binstall via prebuilt binary (fast), falling back to source build
if ! command -v cargo-binstall &>/dev/null; then
  echo "Installing cargo-binstall..."
  if BINSTALL_VERSION=1.14.3 curl -L --proto '=https' --tlsv1.2 -sSf \
      https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash; then
    echo "Installed cargo-binstall (prebuilt)."
  else
    echo "Prebuilt install failed, falling back to cargo install..."
    cargo install cargo-binstall@1.14.3 --locked \
      && echo "Installed cargo-binstall." \
      || echo "WARNING: failed to install cargo-binstall; skipping."
  fi
fi

install_step cargo-nextest \
  cargo binstall --no-confirm --no-discover-github-token cargo-nextest

install_step wgslfmt \
  cargo install --git https://github.com/wgsl-analyzer/wgsl-analyzer --tag "2025-06-28" wgslfmt

echo "Session start hook complete."
