# expect: red Build and test
# null.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y: String | Null = null
EOF
scripts/format >/dev/null
