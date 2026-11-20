# expect: red Modules
# A new requirement with no go.sum lines.
awk '$0 == "require pgregory.net/rapid v1.3.0" { print "require ("; print "\tgolang.org/x/text v0.20.0"; print "\tpgregory.net/rapid v1.3.0"; print ")"; next } { print }' go.mod >x.tmp && mv x.tmp go.mod
