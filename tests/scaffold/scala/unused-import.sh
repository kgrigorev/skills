# expect: red Build and test
# An unused import.
perl -0pi -e 's/package sampletool\n\n/package sampletool\n\nimport java.util.Locale\n\n/' src/main/scala/SampleTool.scala
scripts/format >/dev/null
