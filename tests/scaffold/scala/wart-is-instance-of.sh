# expect: red Build and test
# isInstanceOf.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y(a: Matchable): Boolean = a.isInstanceOf[String]
EOF
scripts/format >/dev/null
