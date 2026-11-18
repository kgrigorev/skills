# expect: red Tool pins in mise.toml and mise.lock
# A dotted-key tool pin outside [tools].
printf 'tools.java = "temurin-21.0.5+11.0.LTS"\n' > mise.toml.new
cat mise.toml >> mise.toml.new
mv mise.toml.new mise.toml
