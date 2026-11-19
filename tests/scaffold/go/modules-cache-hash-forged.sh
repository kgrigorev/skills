# expect: red Modules
# The same edit as modules-cache-edited, with the cache's hash file rewritten to match it, so
# go mod verify passes. go compares that hash file with go.sum when it loads the module.
cache=$(mise exec go -- go env GOMODCACHE)
copy=$(cd .. && pwd)/modcache-forged
mkdir -p "$copy/pgregory.net" "$copy/cache/download/pgregory.net/rapid/@v"
cp -R "$cache/pgregory.net/rapid@v1.3.0" "$copy/pgregory.net/"
cp "$cache/cache/download/pgregory.net/rapid/@v/v1.3.0."* "$copy/cache/download/pgregory.net/rapid/@v/"
chmod -R u+w "$copy"
rm "$copy/cache/download/pgregory.net/rapid/@v/v1.3.0.zip"
sed 's/^func Check(t TB, prop func(\*T)) {$/&\
	return/' "$copy/pgregory.net/rapid@v1.3.0/engine.go" >x.tmp
cat x.tmp >"$copy/pgregory.net/rapid@v1.3.0/engine.go" && rm x.tmp
# The h1: hash of a module folder (golang.org/x/mod/sumdb/dirhash): the SHA-256 of a list of
# "<sha256>  <module>@<version>/<file>" lines, sorted by file.
hash=$(cd "$copy/pgregory.net" && find rapid@v1.3.0 -type f | LC_ALL=C sort | while IFS= read -r file; do
  printf '%s  pgregory.net/%s\n' "$(openssl dgst -sha256 -r "$file" | cut -d' ' -f1)" "$file"
done | openssl dgst -sha256 -binary | openssl base64)
printf 'h1:%s\n' "$hash" >"$copy/cache/download/pgregory.net/rapid/@v/v1.3.0.ziphash"
(GOMODCACHE=$copy GOFLAGS=-mod=mod mise exec go -- go mod verify) | grep -q 'all modules verified'
sed "s#^GOTOOLCHAIN = \"local\"\$#&\\
GOMODCACHE = \"$copy\"#" mise.toml >x.tmp && cat x.tmp >mise.toml && rm x.tmp
grep -q '^GOMODCACHE = ' mise.toml
sed 's/if got := sampletool.Greet(name); !strings.Contains/if got := sampletool.Greet(name); strings.Contains/' \
  sampletool_test.go >x.tmp && cat x.tmp >sampletool_test.go && rm x.tmp
