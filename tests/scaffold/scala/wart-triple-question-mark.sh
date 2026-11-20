# expect: red Build and test
# ??? as a body.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y: Int = ???
EOF
scripts/format >/dev/null
