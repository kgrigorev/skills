# expect: red No switched-off checks in the compiled code
# A ".fail" test registered from a splice in a multi-line string, on a line that starts with //,
# which the scan skips as a comment-only line. The body uses munit.Assertions, so the init
# checker sees no reference to the suite being built.
cat > src/test/scala/NotesSuite.scala <<'X'
package sampletool

class NotesSuite extends munit.FunSuite:
  val notes = s"""
  // ${test("broken".fail)(munit.Assertions.assertEquals(SampleTool.greet("a"), "nope")); ""}
  """

  test("notes are kept"):
    assert(notes.nonEmpty)
X
scripts/format >/dev/null
# shellcheck disable=SC2016 # a literal ${ in Scala code
grep -q '^  // \${test("broken".fail)' src/test/scala/NotesSuite.scala
