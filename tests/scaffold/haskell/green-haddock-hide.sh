# expect: green
# OPTIONS_HADDOCK only changes the generated docs.
perl -0pi -e 's/\A/{-# OPTIONS_HADDOCK hide #-}\n/' src/SampleTool.hs
scripts/format >/dev/null 2>&1 || true
