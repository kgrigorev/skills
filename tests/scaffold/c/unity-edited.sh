# expect: red No switched-off checks
# An edit to the vendored Unity, which is built without the gates and decides what passes.
printf '/* x */\n' >>third_party/unity/unity.c
