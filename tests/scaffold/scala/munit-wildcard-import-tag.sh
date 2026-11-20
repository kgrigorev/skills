# expect: red No switched-off checks
# Fail reached through import munit.*, without the munit. prefix.
cat > src/test/scala/SampleToolSuite.scala <<'X'
package sampletool

import munit.*

class SampleToolSuite extends FunSuite:
  private val broken = "broken".tag

  test(broken(Fail)):
    assertEquals(SampleTool.greet("a"), "nope")
X
scripts/format >/dev/null
