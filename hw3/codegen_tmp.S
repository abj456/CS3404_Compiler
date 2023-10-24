.global codegen
codegen:
//FUNC START
  addi sp, sp, -104
  sd sp, 96(sp)
  sd s0, 88(sp)
  sd s1, 80(sp)
  sd s2, 72(sp)
  sd s3, 64(sp)
  sd s4, 56(sp)
  sd s5, 48(sp)
  sd s6, 40(sp)
  sd s7, 32(sp)
  sd s8, 24(sp)
  sd s9, 16(sp)
  sd s10, 8(sp)
  sd s11, 0(sp)
  addi s0, sp, 104

//INTEGER
  li t0, 42
  addi sp, sp, -8
  sd t0, 0(sp)
//INTEGER
  li t0, 53
  addi sp, sp, -8
  sd t0, 0(sp)
//INTEGER
  li t0, 2
  addi sp, sp, -8
  sd t0, 0(sp)
//MUL
  ld t1, 0(sp)
  addi sp, sp, 8
  ld t0, 0(sp)
  addi sp, sp, 8
  mul t0, t0, t1
  addi sp, sp, -8
  sd t0, 0(sp)
//SUB
  ld t1, 0(sp)
  addi sp, sp, 8
  ld t0, 0(sp)
  addi sp, sp, 8
  sub t0, t0, t1
  addi sp, sp, -8
  sd t0, 0(sp)
//variable assignment
  ld t0, 0(sp)
  addi sp, sp, 8
  sd t0, -40(fp)
  sd t0, 0(sp)

//ASSIGN ADDRESS TO POINTER
  addi t0, fp, -40
  addi sp, sp, -8
  sd t0, 0(sp)
//FETCH VALUE FROM VAR: a
  //ld t0, -40(fp)
  //addi sp, sp, -8
  //sd t0, 0(sp)
//pointer variable assignment
  ld t0, 0(sp)
  addi sp, sp, 8
  sd t0, -48(fp)
  sd t0, 0(sp)

//UNARY OP: -
  ld t0, -40(fp)
  sub t0, zero, t0
  addi sp, sp, -8
  sd t0, 0(sp)
//FETCH VALUE FROM VAR: a
  //ld t0, -40(fp)
  //addi sp, sp, -8
  //sd t0, 0(sp)
//INTEGER
  li t0, 8
  addi sp, sp, -8
  sd t0, 0(sp)
//DIV
  ld t1, 0(sp)
  addi sp, sp, 8
  ld t0, 0(sp)
  addi sp, sp, 8
  div t0, t0, t1
  addi sp, sp, -8
  sd t0, 0(sp)
//DEREFERENCE POINTER L
  ld t0, 0(sp)
  addi sp, sp, 8
  ld t2, -48(fp)
  //ld t1, 0(t2)
  sd t0, 0(t2)
  ld t1, -40(fp)
  ld t3, 0(t4)
  sd t0, 0(sp)


//FUNC END
  addi sp, s0, -104
  ld sp, 96(sp)
  ld s0, 88(sp)
  ld s1, 80(sp)
  ld s2, 72(sp)
  ld s3, 64(sp)
  ld s4, 56(sp)
  ld s5, 48(sp)
  ld s6, 40(sp)
  ld s7, 32(sp)
  ld s8, 24(sp)
  ld s9, 16(sp)
  ld s10, 8(sp)
  ld s11, 0(sp)
  addi sp, sp, 104
  jalr zero, 0(ra)

