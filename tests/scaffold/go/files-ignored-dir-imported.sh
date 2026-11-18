# expect: red Every file is checked
# The command imports a package that git ignores and ./... skips.
printf '_scratch/\n' >>.gitignore
mkdir -p _scratch
printf 'package bad\n\nimport "os"\n\nfunc Bad() { f, _ := os.Open("x"); f.Close() }\n' >_scratch/bad.go
awk '
  $0 == "\t\"example.com/sample-tool\"" { print; print "\tbad \"example.com/sample-tool/_scratch\""; next }
  $0 == "\tfmt.Println(sampletool.Banner())" { print; print "\tbad.Bad()"; next }
  { print }' cmd/sample-tool/main.go >x.tmp && mv x.tmp cmd/sample-tool/main.go
