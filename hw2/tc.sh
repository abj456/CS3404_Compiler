make
mfile="./test/test"

k1file="./test/koihia_tests/1.c"
k2file="./test/koihia_tests/12447.c"
k3file="./test/koihia_tests/array_declaration.c"
k4file="./test/koihia_tests/dev.c"
k5file="./test/koihia_tests/expression.c"
k6file="./test/koihia_tests/function_declaration.c"
k7file="./test/koihia_tests/function_definition.c"
k8file="./test/koihia_tests/scalar_declaration.c"
k9file="./test/koihia_tests/statement.c"

p1file="./test/popo_testcases/expr1.c"
p2file="./test/popo_testcases/expr2.c"
p3file="./test/popo_testcases/functionDeclaration.c"
p4file="./test/popo_testcases/scalarAndArrayWithInit.c"
p5file="./test/popo_testcases/scalarAndArrayWithoutInit.c"
p6file="./test/popo_testcases/stmt.c"
p7file="./test/popo_testcases/test1.c"
p8file="./test/popo_testcases/test2.c"
p9file="./test/popo_testcases/test3.c"
p10file="./test/popo_testcases/test4.c"
p11file="./test/popo_testcases/test5.c"
p12file="./test/popo_testcases/test6.c"
p13file="./test/popo_testcases/wtf.c"

cfile="./test/in.c"

s1file="./scoring_testcase/array_decl_wo_init.txt"
s2file="./scoring_testcase/expr_1.txt"
s3file="./scoring_testcase/expr_2.txt"
s4file="./scoring_testcase/expr_3.txt"
s5file="./scoring_testcase/func_decl.txt"
s6file="./scoring_testcase/func_def.txt"
s7file="./scoring_testcase/scalar_decl_wo_init.txt"
s8file="./scoring_testcase/stmt.txt"
s9file="./scoring_testcase/var_decl.txt"
file=$k9file

echo "$file"
# ./parser < $file
diff  <(./parser < $file) <(golden_parser < $file)


