# expect: red No switched-off checks
# CanEqual[AnyVal, AnyVal].
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  given CanEqual[AnyVal, AnyVal] = CanEqual.derived

  /** y */
  def same(a: Int, b: Long): Boolean = a == b
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
