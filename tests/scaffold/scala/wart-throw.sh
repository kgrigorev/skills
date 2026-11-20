# expect: red Build and test
# throw.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y(n: Int): Int = if n > 0 then n else throw new IllegalArgumentException("neg")
EOF
scripts/format >/dev/null
