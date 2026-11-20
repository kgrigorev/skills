# expect: red No switched-off checks
# @SuppressWarnings switches off a WartRemover wart.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  @SuppressWarnings(Array("org.wartremover.warts.Var"))
  def y: Int =
    var n = 1
    n = 2
    n
EOF
scripts/format >/dev/null
