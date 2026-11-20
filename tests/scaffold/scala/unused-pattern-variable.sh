# expect: red Build and test
# An unused pattern variable.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y(o: Option[Int]): Int = o match
    case Some(v) => 1
    case None    => 0
EOF
scripts/format >/dev/null
