# expect: red No switched-off checks
# A test file in package munit sees Fail without a prefix. Two package clauses open munit's
# members; a single `package munit.hack` would not.
cat > src/test/scala/Hack.scala <<'X'
package munit
package hack

import sampletool.SampleTool

class HackSuite extends munit.FunSuite:
  private val broken = "broken".tag

  test(broken(Fail)):
    assertEquals(SampleTool.greet("a"), "nope")
X
mise exec -- scala-cli fmt project.scala src >/dev/null
