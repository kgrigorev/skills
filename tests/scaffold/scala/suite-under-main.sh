# expect: red Build and test
# A failing suite in a test/ folder under src/main still runs.
mkdir -p src/main/scala/test
cat > src/main/scala/test/BrokenSuite.scala <<'EOF'
package sampletool

class BrokenSuite extends munit.FunSuite:
  test("broken"):
    assertEquals(SampleTool.greet("a"), "nope")
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
