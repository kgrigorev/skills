# expect: red Modules
# An edited module cache: rapid.Check returns at once, so a broken property passes. go checks
# go.sum only on download, so only go mod verify sees the edit. The copy sits outside the
# project, and mise.toml points GOMODCACHE at it, the way an agent would edit ~/go/pkg/mod.
cache=$(mise exec go -- go env GOMODCACHE)
copy=$(cd .. && pwd)/modcache-edited
mkdir -p "$copy/pgregory.net" "$copy/cache/download/pgregory.net/rapid/@v"
cp -R "$cache/pgregory.net/rapid@v1.3.0" "$copy/pgregory.net/"
cp "$cache/cache/download/pgregory.net/rapid/@v/v1.3.0."* "$copy/cache/download/pgregory.net/rapid/@v/"
chmod -R u+w "$copy"
sed 's/^func Check(t TB, prop func(\*T)) {$/&\
	return/' "$copy/pgregory.net/rapid@v1.3.0/engine.go" >x.tmp
cat x.tmp >"$copy/pgregory.net/rapid@v1.3.0/engine.go" && rm x.tmp
grep -A1 '^func Check(' "$copy/pgregory.net/rapid@v1.3.0/engine.go" | grep -q return
sed "s#^GOTOOLCHAIN = \"local\"\$#&\\
GOMODCACHE = \"$copy\"#" mise.toml >x.tmp && cat x.tmp >mise.toml && rm x.tmp
grep -q '^GOMODCACHE = ' mise.toml
sed 's/if got := sampletool.Greet(name); !strings.Contains/if got := sampletool.Greet(name); strings.Contains/' \
  sampletool_test.go >x.tmp && cat x.tmp >sampletool_test.go && rm x.tmp
grep -q '; strings.Contains' sampletool_test.go
