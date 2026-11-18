# expect: green
# Ordinary repository housekeeping: line-ending attributes, a docs folder, a README change.
printf '* text=auto eol=lf\n*.png binary\n' >.gitattributes
mkdir -p docs
cat >docs/usage.md <<'MD'
# Usage

Run `sample-tool` with words to print their slug. Comments such as `# noqa` or
`pytest.skip` are not allowed in the code; this file is not code.
MD
printf '\nSee docs/usage.md.\n' >>README.md
