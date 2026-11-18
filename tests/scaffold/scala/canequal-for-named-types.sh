# expect: green
# CanEqual for a named Java type, and a type alias to a real type.
cat > src/main/scala/Clock.scala <<'EOF'
package sampletool

import java.time.Instant

/** Equality for the Java time types this tool compares. */
object Clock:
  given CanEqual[Instant, Instant] = CanEqual.derived

  /** An amount of money. */
  type Amount = BigDecimal

  /** Whether two instants are the same. */
  def same(a: Instant, b: Instant): Boolean = a == b

  /** The larger of two amounts. */
  def larger(a: Amount, b: Amount): Amount = a.max(b)
EOF
cat >> src/test/scala/SampleToolSuite.scala <<'EOF'

  test("a tagged name keeps its tag"):
    assertEquals(SampleTool.greet("tag"), "Hello, tag!")

  test("an instant equals itself"):
    val now = java.time.Instant.EPOCH
    assert(Clock.same(now, now))
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
