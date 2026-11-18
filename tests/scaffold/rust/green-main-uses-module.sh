# expect: green
# main.rs reads arguments and returns an exit code through the library.
cat > src/main.rs <<'R'
//! The sample-tool program. It only calls the library, so tests reach all the logic.

use std::process::ExitCode;

fn main() -> ExitCode {
    println!("{}", sample_tool::banner());
    let words: usize = std::env::args().skip(1).map(|arg| sample_tool::word_count(&arg)).sum();
    println!("{words}");
    if words == 0 { ExitCode::FAILURE } else { ExitCode::SUCCESS }
}
R
mise exec -- cargo fmt --all
