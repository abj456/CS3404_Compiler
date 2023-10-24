.global codegen
codegen:
#FUNC START
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

#INTEGER
  li t0, 65280
  addi sp, sp, -8
  sd t0, 0(sp)
#variable assignment
  ld t0, 0(sp)
  addi sp, sp, 8
  sd t0, -40(fp)
  addi sp, sp, -8
  sd t0, 0(sp)

#INTEGER
  li t0, 259
  addi sp, sp, -8
  sd t0, 0(sp)
#variable assignment
  ld t0, 0(sp)
  addi sp, sp, 8
  sd t0, -48(fp)
  addi sp, sp, -8
  sd t0, 0(sp)

#CHAR4 ADD
  lw t1, 0(sp)
  addi sp, sp, 8
  lw t0, 0(sp)
  addi sp, sp, 8
  KADD8 t0, t0, t1
  addi sp, sp, -8
  sw t0, 0(sp)
#variable assignment
  ld t0, 0(sp)
  addi sp, sp, 8
  sd t0, -56(fp)
  addi sp, sp, -8
  sd t0, 0(sp)

#INTEGER
  li t0, 26
  addi sp, sp, -8
  sd t0, 0(sp)
#ARGUMENT
#TRANSFORM HIGH TO 1
  li t0, 1
  addi sp, sp, -8
  sd t0, 0(sp)
#ARGUMENT

#FUNCTION INVOCATION
  ld a0, 8(sp)
  ld a1, 0(sp)
  addi sp, sp, -8
  sd ra, 0(sp)
  jal ra, digitalWrite
  ld ra, 0(sp)
  addi sp, sp, 8
#RETURN TO CALLER

#FETCH VALUE FROM VAR: c
  ld t0, -56(fp)
  addi sp, sp, -8
  sd t0, 0(sp)
#INTEGER
  li t0, 1000
  addi sp, sp, -8
  sd t0, 0(sp)
#MUL
  ld t1, 0(sp)
  addi sp, sp, 8
  ld t0, 0(sp)
  addi sp, sp, 8
  mul t0, t0, t1
  addi sp, sp, -8
  sd t0, 0(sp)
#ARGUMENT

#FUNCTION INVOCATION
  ld a0, 0(sp)
  addi sp, sp, -8
  sd ra, 0(sp)
  jal ra, delay
  ld ra, 0(sp)
  addi sp, sp, 8
#RETURN TO CALLER

#INTEGER
  li t0, 26
  addi sp, sp, -8
  sd t0, 0(sp)
#ARGUMENT
#TRANSFORM LOW TO 0
  li t0, 0
  addi sp, sp, -8
  sd t0, 0(sp)
#ARGUMENT

#FUNCTION INVOCATION
  ld a0, 8(sp)
  ld a1, 0(sp)
  addi sp, sp, -8
  sd ra, 0(sp)
  jal ra, digitalWrite
  ld ra, 0(sp)
  addi sp, sp, 8
#RETURN TO CALLER

#FETCH VALUE FROM VAR: c
  ld t0, -56(fp)
  addi sp, sp, -8
  sd t0, 0(sp)
#INTEGER
  li t0, 1000
  addi sp, sp, -8
  sd t0, 0(sp)
#MUL
  ld t1, 0(sp)
  addi sp, sp, 8
  ld t0, 0(sp)
  addi sp, sp, 8
  mul t0, t0, t1
  addi sp, sp, -8
  sd t0, 0(sp)
#ARGUMENT

#FUNCTION INVOCATION
  ld a0, 0(sp)
  addi sp, sp, -8
  sd ra, 0(sp)
  jal ra, delay
  ld ra, 0(sp)
  addi sp, sp, 8
#RETURN TO CALLER

#FUNC END
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

