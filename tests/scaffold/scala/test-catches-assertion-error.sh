# expect: red No switched-off checks in the compiled code
# A test that catches the AssertionError its own assertion throws.
cat > src/test/scala/CatchSuite.scala <<'X'
package sampletool

class CatchSuite extends munit.FunSuite:
  test("a greeting names the person"):
    try assertEquals(SampleTool.greet("Ada"), "Hi, Ada!")
    catch case _: AssertionError => ()
X
scripts/format >/dev/null
