# expect: red Build and test
# Either.left.get.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y(e: Either[String, Int]): String = e.left.get
EOF
scripts/format >/dev/null
