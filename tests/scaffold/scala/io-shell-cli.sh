# expect: green
# A CLI run pattern: Main reads a file named on the command line, a pure core parses it, errors
# go to stderr with exit status 1. The core is tested; the shell is not.
cat > src/main/scala/Main.scala <<'X'
package sampletool

import java.nio.charset.StandardCharsets
import java.nio.file.{Files, NoSuchFileException, Path}

/** Greets every name in the file given on the command line, one name per line. */
@main def run(args: String*): Unit =
  Cli.arguments(args.toList).flatMap(read).flatMap(Names.parse) match
    case Right(names) => names.map(SampleTool.greet).foreach(println)
    case Left(problem) =>
      System.err.println(Cli.describe(problem))
      sys.exit(1)

/** Reads the whole file, turning the expected failure into a value. */
private def read(path: Path): Either[Cli.Problem, String] =
  try Right(Files.readString(path, StandardCharsets.UTF_8))
  catch case _: NoSuchFileException => Left(Cli.Problem.Missing(path.toString))
X
cat > src/main/scala/Cli.scala <<'X'
package sampletool

import java.nio.file.Path

/** The command line: one argument, the path of a names file. */
object Cli:

  /** What can go wrong before any name is greeted. */
  enum Problem derives CanEqual:
    case Usage
    case Missing(path: String)
    case Empty

  /** The path from the arguments, or a usage problem. */
  def arguments(args: List[String]): Either[Problem, Path] = args match
    case List(path) => Right(Path.of(path))
    case _          => Left(Problem.Usage)

  /** A message for the user. */
  def describe(problem: Problem): String = problem match
    case Problem.Usage         => "usage: sample-tool <names-file>"
    case Problem.Missing(path) => s"no such file: $path"
    case Problem.Empty         => "the file holds no names"

/** Reads the names file. */
object Names:
  /** The non-blank lines, or Empty. */
  def parse(text: String): Either[Cli.Problem, List[String]] =
    val names = text.linesIterator.map(_.trim).filter(_.nonEmpty).toList
    if names.isEmpty then Left(Cli.Problem.Empty) else Right(names)
X
cat > src/test/scala/CliSuite.scala <<'X'
package sampletool

import java.nio.file.Path

class CliSuite extends munit.FunSuite:

  test("one argument is the path"):
    assertEquals(Cli.arguments(List("names.txt")), Right(Path.of("names.txt")))

  test("two arguments are a usage problem"):
    assertEquals(Cli.arguments(List("a", "b")), Left(Cli.Problem.Usage))

  test("blank lines are skipped"):
    assertEquals(Names.parse("Ada\n\n  Grace \n"), Right(List("Ada", "Grace")))

  test("a file of blank lines is empty"):
    assertEquals(Names.parse("\n \n"), Left(Cli.Problem.Empty))
X
scripts/format >/dev/null
