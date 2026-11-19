# expect: green
# Main code cannot see munit, so its words are domain names there: a builder named withTags, a
# check named isCI, a class whose name ends in ValueTransform, a method named assume.
cat > src/main/scala/Post.scala <<'X'
package sampletool

/** A blog post. */
final case class Post(title: String, tags: List[String]) derives CanEqual:
  /** The post with other tags. */
  def withTags(more: List[String]): Post = copy(tags = more)

/** Where the tool runs. */
object Env:
  /** Whether the tool runs on a CI server. */
  def isCI(env: Map[String, String]): Boolean = env.contains("CI")

/** Scales a pixel value. */
final case class PixelValueTransform(factor: Int):
  /** The scaled value. */
  def applyTo(value: Int): Int = value * factor

/** Who may do what. */
object Policy:
  /** The role a user takes when none is given. */
  def assume(role: Option[String]): String = role.getOrElse("guest")
X
cat > src/test/scala/PostSuite.scala <<'X'
package sampletool

// Test files still may not name withTags, isCI or assume: the printout does not show whether a
// call goes to munit or to main code.
class PostSuite extends munit.FunSuite:
  test("a post keeps its tags"):
    assertEquals(Post("a", List("x")).tags, List("x"))
    assertEquals(PixelValueTransform(2).applyTo(3), 6)
X
mise exec -- scala-cli fmt project.scala src >/dev/null
