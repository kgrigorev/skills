# expect: red No switched-off checks
# CanEqual[scala.Any, scala.Any].
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  given CanEqual[scala.Any, scala.Any] = CanEqual.derived

  /** y */
  def same(a: Int, b: String): Boolean = a == b
EOF
scripts/format >/dev/null
