# expect: red No switched-off checks
# A CanEqual[Any, Any] given brings back universal equality.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  given CanEqual[Any, Any] = CanEqual.derived

  /** y */
  def same(a: Int, b: String): Boolean = a == b
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
