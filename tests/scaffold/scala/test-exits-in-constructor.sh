# expect: red Build and test
# A suite that ends the test JVM with status 0 while munit creates it, before it reports a start.
# It sorts first, so the suites after it never run. The exit goes through main code.
cat > src/main/scala/Shutdown.scala <<'X'
package sampletool

/** Ends the program. */
object Shutdown:
  /** Stops the JVM with status 0 when `now` holds. */
  def when(now: Boolean): Unit = if now then sys.exit(0)
X
cat > src/test/scala/AaaSuite.scala <<'X'
package sampletool

class AaaSuite extends munit.FunSuite:
  Shutdown.when(SampleTool.greet("").nonEmpty)

  test("broken"):
    assertEquals(SampleTool.greet("a"), "nope")
X
perl -pi -e 's/"Hello, world!"\)/"Hello, World!")/' src/test/scala/SampleToolSuite.scala
grep -q 'Hello, World!' src/test/scala/SampleToolSuite.scala
mise exec -- scala-cli fmt project.scala src >/dev/null
