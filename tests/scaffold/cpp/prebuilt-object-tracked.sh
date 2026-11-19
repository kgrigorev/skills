# expect: red Only .cpp and .hpp files
# A prebuilt object file in the project.
. "$(dirname "$0")/lib/attack"
printf 'not really an object\n' >tests/hook.o
