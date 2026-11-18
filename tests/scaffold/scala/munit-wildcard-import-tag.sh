# expect: red No switched-off checks
# Fail reached through import munit.*, without the munit. prefix.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

import munit.*

class SampleToolSuite extends FunSuite:
  test(testOptionsFromString("broken").copy(tags = Set(Fail))):
    assertEquals(SampleTool.greet("a"), "nope")
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
