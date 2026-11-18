# expect: red No switched-off checks
# The hspec-discover driver with an extra warning switch.
printf '{-# OPTIONS_GHC -F -pgmF hspec-discover -Wno-missing-export-lists #-}\n' >test/Main.hs
