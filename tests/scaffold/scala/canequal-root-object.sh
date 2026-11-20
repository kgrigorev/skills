# expect: red No switched-off checks
# CanEqual[_root_.java.lang.Object, ...].
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  given CanEqual[_root_.java.lang.Object, _root_.java.lang.Object] = CanEqual.derived

  /** y */
  def same(a: String, b: java.util.UUID): Boolean = a == b
EOF
scripts/format >/dev/null
