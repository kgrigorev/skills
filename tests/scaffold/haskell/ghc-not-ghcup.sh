# expect: red Pinned tools
# GHC must be ghcup's build. With ghcup's folder elsewhere, the pinned GHC is not found there.
# env: GHCUP_INSTALL_BASE_PREFIX=/nonexistent
true
