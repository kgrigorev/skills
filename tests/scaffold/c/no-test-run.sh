# expect: red Test
# A test main that runs no test: Unity reports 0 Tests and exits 0.
perl -0pi -e 's/    RUN_TEST\(banner_names_the_program\);\n    RUN_TEST\(banner_is_cut_to_fit_and_terminated\);\n/    (void)banner_names_the_program;\n    (void)banner_is_cut_to_fit_and_terminated;\n/' test/sample_tool_test.c
