riscv64-unknown-elf-gcc -o sample_prog ./assembly/main.c codegen.S
spike  pk sample_prog

# riscv64-unknown-elf-as-rvp -march=rv64g_zpn -o codegen.o codegen.S
# riscv64-unknown-elf-gcc -o sample_prog ./assembly/main.c codegen.o
# spike  pk sample_prog