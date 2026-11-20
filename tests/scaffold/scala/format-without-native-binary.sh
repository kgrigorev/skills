# expect: green
# env: COURSIER_ARCHIVE_CACHE=/dev/null/no-archives
# The format step runs scalafmt on the JVM. `scala-cli fmt` would fetch scalafmt's native binary
# into the archive cache, which cannot be created here, so a return to that binary turns this red.
# The binary corrupts memory now and then on Linux; DESIGN.md says when to go back to it.
true
