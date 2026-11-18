# expect: green
# A struct with FromStr, Display, an error type with source(), a doc example using ?, and
# main returning Result.
cat > src/config.rs <<'R'
//! `key=value` settings.

use std::collections::BTreeMap;
use std::fmt;
use std::num::ParseIntError;
use std::str::FromStr;

/// A setting line that could not be read.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum SettingError {
    /// The line has no `=`.
    NoEquals(String),
    /// The width is not a number.
    BadWidth(ParseIntError),
}

impl fmt::Display for SettingError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::NoEquals(line) => write!(f, "{line:?} has no '='"),
            Self::BadWidth(_) => write!(f, "the width is not a number"),
        }
    }
}

impl std::error::Error for SettingError {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        match self {
            Self::NoEquals(_) => None,
            Self::BadWidth(error) => Some(error),
        }
    }
}

/// Settings read from text.
#[derive(Debug, Default, Clone, PartialEq, Eq)]
pub struct Settings {
    values: BTreeMap<String, String>,
}

impl Settings {
    /// The value of `key`, if set.
    #[must_use]
    pub fn get(&self, key: &str) -> Option<&str> {
        self.values.get(key).map(String::as_str)
    }

    /// The `width` setting, 80 when unset.
    ///
    /// # Errors
    ///
    /// When `width` is set but is not a number.
    ///
    /// ```
    /// let settings: sample_tool::config::Settings = "width = 72".parse()?;
    /// assert_eq!(settings.width()?, 72);
    /// # Ok::<(), sample_tool::config::SettingError>(())
    /// ```
    pub fn width(&self) -> Result<u16, SettingError> {
        self.get("width").map_or(Ok(80), |text| text.parse().map_err(SettingError::BadWidth))
    }
}

impl FromStr for Settings {
    type Err = SettingError;

    fn from_str(text: &str) -> Result<Self, Self::Err> {
        let mut values = BTreeMap::new();
        for line in text.lines().map(str::trim).filter(|line| !line.is_empty() && !line.starts_with('#')) {
            let (key, value) = line.split_once('=').ok_or_else(|| SettingError::NoEquals(line.to_owned()))?;
            values.insert(key.trim().to_owned(), value.trim().to_owned());
        }
        Ok(Self { values })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn comments_and_blank_lines_are_skipped() -> Result<(), SettingError> {
        let settings: Settings = "# a comment\n\nname = x\n".parse()?;
        assert_eq!(settings.get("name"), Some("x"));
        Ok(())
    }

    #[test]
    fn a_line_without_equals_is_an_error() {
        let error = "oops".parse::<Settings>().unwrap_err();
        assert_eq!(error, SettingError::NoEquals(String::from("oops")));
    }
}
R
printf '\npub mod config;\n' >> src/lib.rs
cat > src/main.rs <<'R'
//! The sample-tool program. It only calls the library, so tests reach all the logic.

use std::error::Error;
use std::io::Read;

fn main() -> Result<(), Box<dyn Error>> {
    println!("{}", sample_tool::banner());
    let mut text = String::new();
    std::io::stdin().read_to_string(&mut text)?;
    let settings: sample_tool::config::Settings = text.parse()?;
    println!("width {}", settings.width()?);
    Ok(())
}
R
mise exec -- cargo fmt --all
