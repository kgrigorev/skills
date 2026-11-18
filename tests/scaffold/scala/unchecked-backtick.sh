# expect: red No switched-off checks
# @`unchecked` on a refutable pattern.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y(o: Option[Int]): Int =
    val Some(v) = o: @`unchecked`
    v
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
