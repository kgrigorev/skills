# expect: red No switched-off checks in the compiled code
# .runtimeChecked: the Scala 3.8+ spelling of ": @unchecked" on a refutable pattern.
cat > src/main/scala/X.scala <<'X'
package sampletool

/** x */
object X:
  /** y */
  def y(o: Option[Int]): Int =
    val Some(v) = o.runtimeChecked
    v
X
mise exec -- scala-cli fmt project.scala src >/dev/null
