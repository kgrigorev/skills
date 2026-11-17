# expect: red No switched-off checks
# An HLint ignore annotation in the library.
printf '\n{-# ANN module "HLint: ignore" #-}\n' >> src/SampleTool.hs
