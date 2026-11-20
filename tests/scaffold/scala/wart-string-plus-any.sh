# expect: red Build and test
# A String plus a non-String value.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y(n: Int): String = "n=" + n
EOF
scripts/format >/dev/null
