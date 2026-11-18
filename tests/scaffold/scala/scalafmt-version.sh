# expect: red Format rules fixed in .scalafmt.conf
# Another scalafmt version formats differently from CI.
perl -pi -e 's/^version = .*/version = 3.8.0/' .scalafmt.conf
grep -q 3.8.0 .scalafmt.conf
