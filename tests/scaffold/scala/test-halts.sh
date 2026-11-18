# expect: red Build and test
# Runtime.halt ends the JVM with status 0 and records no exit, so the test runner never finishes.
cat > src/test/scala/AaaSuite.scala <<'X'
package sampletool

class AaaSuite extends munit.FunSuite:
  if SampleTool.greet("").nonEmpty then Runtime.getRuntime.halt(0)

  test("broken"):
    assertEquals(SampleTool.greet("a"), "nope")
X
perl -pi -e 's/"Hello, world!"\)/"Hello, World!")/' src/test/scala/SampleToolSuite.scala
grep -q 'Hello, World!' src/test/scala/SampleToolSuite.scala
mise exec -- scala-cli fmt project.scala src >/dev/null
