# expect: green
# env: GIT_CONFIG_GLOBAL=.git/test-global-config
# A personal global gitignore that lists .claude/ must not make the committed .claude/ files
# count as "committed but ignored": only the project's .gitignore files count.
printf '.claude/\n' >.git/test-global-excludes
printf '[core]\n\texcludesFile = %s/.git/test-global-excludes\n' "$(pwd)" >.git/test-global-config
