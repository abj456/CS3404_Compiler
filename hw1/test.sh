./scanner < ./scoring_testcase/string.txt > string.out
golden_scanner < ./scoring_testcase/string.txt > gs_string.out
diff -e string.out gs_string.out > ./diff/diff_string.txt