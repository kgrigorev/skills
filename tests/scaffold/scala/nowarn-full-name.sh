# expect: red No switched-off checks
# @annotation.nowarn written in full, on an unused private method.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  @annotation.nowarn
  private def unused(): Int = 1

  /** y */
  def y: Int = 2
EOF
scripts/format >/dev/null
