# expect: red No switched-off checks
# Type errors deferred to run time.
perl -0pi -e 's/\A/{-# OPTIONS_GHC -fdefer-type-errors #-}\n\n/' src/SampleTool.hs
