# expect: green
# A module setting in the [env] table of mise.toml, where DESIGN.md says it belongs.
awk '{ print } /^\[env\]$/ { print "GOPRIVATE = \"example.com/private\"" }' mise.toml >x.tmp && mv x.tmp mise.toml
