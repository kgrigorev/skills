# expect: green
# env: JAVA_TOOL_OPTIONS=-XX:+NoSuchOption
# env: JDK_JAVA_OPTIONS=-XX:+NoSuchOption
# env: _JAVA_OPTIONS=-XX:+NoSuchOption
# Every JVM reads these variables, so one could load a -javaagent into scalafmt, the compiler or
# the tests and change what they report. The check runs without them: a JVM that read this value
# would refuse to start.
true
