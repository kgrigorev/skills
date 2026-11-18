# expect: green
# Ordinary block comments whose first word happens to start like a pragma name.
perl -0pi -e 's/\(banner, tidyName\)/(annualTotal, banner, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

{- Annual totals: the ledger closes on the last day of the year. -}

{- Options for the report are read from the command line, see app/Main.hs. -}

-- | The sum of twelve monthly totals.
annualTotal :: [Int] -> Int
annualTotal months = sum (take 12 months)
HS
