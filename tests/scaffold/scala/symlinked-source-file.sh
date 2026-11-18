# expect: red Sources only in src/
# A symlink into src/ from a .txt file outside: compiled, never scanned.
mkdir -p notes
cat > notes/bad.txt <<'EOF'
//> using options -Wconf:any:s
package sampletool

object Bad:
  private def unused(): Int = 1
EOF
ln -s ../../../notes/bad.txt src/main/scala/Bad.scala
