# expect: green
# Tests with #[ignore = ...], should_panic(expected), a Result return, and nested modules.
cat >> tests/sample_tool.rs <<'R'

#[test]
#[ignore = "slow on CI"]
fn ignored_tests_still_run() {
    assert_eq!(word_count("a b c"), 3);
}

#[test]
#[should_panic(expected = "out of range")]
fn indexing_past_the_end_panics() {
    let words: Vec<&str> = "a b".split_whitespace().collect();
    let index = words.len() + usize::from(banner().is_empty());
    assert!(index < words.len(), "index out of range");
}

#[test]
fn a_test_may_return_a_result() -> Result<(), String> {
    if word_count("a") == 1 {
        Ok(())
    } else {
        Err(String::from("one word expected"))
    }
}

mod nested {
    mod deeper {
        use sample_tool::word_count;

        #[test]
        fn a_test_in_a_nested_module_runs() {
            assert_eq!(word_count("x"), 1);
        }
    }
}
R
mise exec -- cargo fmt --all
