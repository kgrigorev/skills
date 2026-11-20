# expect: red No switched-off checks
# munit imported under another name, then m.Fail through an eta-expanded .tag.
cat > src/test/scala/SampleToolSuite.scala <<'X'
package sampletool

import _root_.munit as m

class SampleToolSuite extends m.FunSuite:
  private val broken = "broken".tag

  test(broken(m.Fail)):
    assertEquals(SampleTool.greet("a"), "nope")
X
scripts/format >/dev/null
