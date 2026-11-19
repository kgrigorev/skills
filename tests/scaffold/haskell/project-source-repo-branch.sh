# expect: red No switched-off checks
# expect-output: source-repository-package needs tag
# A source-repository-package that follows a branch, whose code no step reads.
printf '\nsource-repository-package\n  type: git\n  location: https://example.invalid/x.git\n  tag: main\n' >>cabal.project
scripts/format >/dev/null 2>&1 || true
