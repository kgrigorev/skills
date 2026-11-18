# expect: red Settings files
# A wrapper script runs true instead of the test binaries.
{
  printf 'experimental = ["wrapper-scripts"]\n'
  cat .config/nextest.toml
  printf '\n[scripts.wrapper.pass]\ncommand = "true"\n\n[[profile.default.scripts]]\nfilter = "all()"\nrun-wrapper = "pass"\n'
} > n.tmp
mv n.tmp .config/nextest.toml
perl -pi -e 's/starts_with\("sample-tool"\)/starts_with("nope")/' tests/sample_tool.rs
