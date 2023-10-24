make
k1file="./koihia_tests/1"
k2file="./koihia_tests/12447"
k3file="./koihia_tests/array_declaration"
k4file="./koihia_tests/dev"
k5file="./koihia_tests/expression"
k6file="./koihia_tests/function_declaration"
k7file="./koihia_tests/function_definition"
k8file="./koihia_tests/scalar_declaration"
k9file="./koihia_tests/statement"

mfile="./test"
file=$k9file

echo "$file.c"
diff  <(./parser < $file.c) <(golden_parser < $file.c)


