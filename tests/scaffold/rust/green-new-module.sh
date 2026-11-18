# expect: green
# A new module with a Result-returning function, an error type and unit tests that unwrap.
cat > src/ledger.rs <<'R'
//! Ledger lines: `<name> <amount>`.

use std::fmt;

/// A ledger line that could not be read.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum LineError {
    /// The line has no amount after the name.
    MissingAmount,
    /// The amount is not a whole number.
    BadAmount(String),
}

impl fmt::Display for LineError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::MissingAmount => write!(f, "the line has no amount"),
            Self::BadAmount(text) => write!(f, "{text:?} is not a whole number"),
        }
    }
}

impl std::error::Error for LineError {}

/// Reads the amount from a ledger line.
///
/// # Errors
///
/// When the line has no amount, or the amount is not a whole number.
pub fn amount(line: &str) -> Result<i64, LineError> {
    let text = line.split_whitespace().nth(1).ok_or(LineError::MissingAmount)?;
    text.parse().map_err(|_| LineError::BadAmount(text.to_owned()))
}

#[cfg(test)]
mod tests {
    use super::{LineError, amount};

    #[test]
    fn reads_the_amount() {
        assert_eq!(amount("rent 1200").unwrap(), 1200);
    }

    #[test]
    fn a_missing_amount_is_an_error() {
        assert_eq!(amount("rent"), Err(LineError::MissingAmount));
    }

    #[test]
    fn a_bad_amount_names_the_text() {
        let error = amount("rent ten").expect_err("ten is not a number");
        assert_eq!(error.to_string(), "\"ten\" is not a whole number");
    }
}
R
printf '\npub mod ledger;\n' >> src/lib.rs
mise exec -- cargo fmt --all
