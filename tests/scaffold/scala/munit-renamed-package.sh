# expect: red No switched-off checks
# munit imported under another name, then m.Fail.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

import _root_.munit as m

class SampleToolSuite extends m.FunSuite:
  test(testOptionsFromString("broken").copy(tags = Set(m.Fail))):
    assertEquals(SampleTool.greet("a"), "nope")
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
