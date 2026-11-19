# expect: red No switched-off checks
# expect-output: the first word of a block comment must be ASCII
# A dotted capital I (U+0130) in OPTİONS_GHC: GHC lower-cases it to "i" and reads OPTIONS_GHC -w,
# while perl case-folds it to "i" and a combining dot, so a case-insensitive match missed it.
perl -0pi -e 's/\A/{-# OPT\x{130}ONS_GHC -w #-}\n/; s/$/\n\n-- | Not used anywhere.\nunusedThing :: Int\nunusedThing = 1\n/' -CSD src/SampleTool.hs
scripts/format >/dev/null 2>&1 || true
