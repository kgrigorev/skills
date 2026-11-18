# expect: red Format rules fixed in .scalafmt.conf
# project.excludePaths skips an unformatted file.
printf 'project.excludePaths = ["glob:**/Bad.scala"]\n' >> .scalafmt.conf
printf 'package sampletool\n/** b */\nobject   Bad   {  /** y */ def y : Int = {2}   }\n' > src/main/scala/Bad.scala
