# expect: red No switched-off checks
# An HLint ANN pragma split over lines.
printf '\n{-# ANN\n  module\n  "HLint: ignore"\n  #-}\n' >>src/SampleTool.hs
