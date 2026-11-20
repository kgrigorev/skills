# expect: red Build and test: test results
# An assertion in another thread: its failure ends that thread and never reaches munit.
cat > src/test/scala/ThreadSuite.scala <<'X'
package sampletool

class ThreadSuite extends munit.FunSuite:
  test("broken"):
    val worker = Thread(() => assertEquals(SampleTool.greet("a"), "nope"))
    worker.start()
    worker.join()
X
scripts/format >/dev/null
