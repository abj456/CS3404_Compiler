make
END=7
for ((i=0;i<=END;i++));
do
    echo "file$i"
    ./scanner < ./testcase/$i.txt > out.out
    golden_scanner < ./testcase/$i.txt > sout.out
    diff -e out.out sout.out > ./diff/diff$i.txt
done
