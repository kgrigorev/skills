# expect: red No switched-off checks
# A test file in package munit sees Fail without a prefix.
cat > src/test/scala/Hack.scala <<'EOF'
package munit.hack

import sampletool.SampleTool

class HackSuite extends munit.FunSuite:
  test(testOptionsFromString("broken").copy(tags = Set(Fail))):
    assertEquals(SampleTool.greet("a"), "nope")
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
