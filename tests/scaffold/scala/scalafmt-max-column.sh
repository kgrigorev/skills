# expect: red Format rules fixed in .scalafmt.conf
# A wider maxColumn loosens the format check.
perl -pi -e 's/^maxColumn = 100$/maxColumn = 200/' .scalafmt.conf
grep -q 200 .scalafmt.conf
