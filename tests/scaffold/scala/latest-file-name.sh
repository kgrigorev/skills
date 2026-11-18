# expect: green
# Main code in a file whose name contains "test" (Latest), using a domain method "property", the
# same name words-in-strings-and-names uses in Rules.scala.
cat > src/main/scala/LatestRelease.scala <<'X'
package sampletool

/** Picks the newest release from a list of release properties. */
object LatestRelease:

  /** One release, as key-value properties. */
  type Release = Map[String, String]

  /** A property of a release, such as "version". */
  def property(release: Release, key: String): Option[String] = release.get(key)

  /** The release with the highest version number. */
  def latest(releases: List[Release]): Option[Release] =
    releases.maxByOption(release => property(release, "version").flatMap(_.toIntOption).getOrElse(0))
X
cat >> src/test/scala/SampleToolSuite.scala <<'X'

  test("the latest release has the highest version"):
    val releases = List(Map("version" -> "2"), Map("version" -> "10"))
    assertEquals(LatestRelease.latest(releases), Some(Map("version" -> "10")))
X
mise exec -- scala-cli fmt project.scala src >/dev/null
