# expect: red Lint
# A deleted test leaves an unused import behind.
perl -0pi -e 's/#\[test\]\nfn banner_starts_with_the_package_name\(\) \{\n.*?\n\}\n//s' tests/sample_tool.rs
mise exec -- cargo fmt --all
