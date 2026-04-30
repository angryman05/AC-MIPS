main:
 addiu	sp,sp,-48
 sw	ra,44(sp)
 sw	s8,40(sp)
 move	s8,sp
 li	v0,15
 sw	v0,36(s8)
 sw	zero,24(s8)
 li	v0,1
 sw	v0,28(s8)
 b	a0 <main+0xa0>
 nop
 lw	v0,36(s8)
 nop
 sw	v0,32(s8)
 b	54 <main+0x54>
 nop
 lw	v1,32(s8)
 lw	v0,28(s8)
 nop
 subu	v0,v1,v0
 sw	v0,32(s8)
 lw	v1,32(s8)
 lw	v0,28(s8)
 nop
 slt	v0,v1,v0
 beqz	v0,40 <main+0x40>
 nop
 lw	v0,32(s8)
 nop
 bnez	v0,90 <main+0x90>
 nop
 lw	v1,24(s8)
 lw	v0,28(s8)
 nop
 addu	v0,v1,v0
 sw	v0,24(s8)
 lw	v0,28(s8)
 nop
 addiu	v0,v0,1
 sw	v0,28(s8)
 lw	v1,28(s8)
 lw	v0,36(s8)
 nop
 slt	v0,v0,v1
 beqz	v0,2c <main+0x2c>
 nop
 lw	a1,24(s8)
 lui	v0,0x0
    R_MIPS_HI16 .rodata
 addiu	a0,v0,0
    R_MIPS_LO16 .rodata
 jal	0 <main>
    R_MIPS_26 printf
 nop
 move	v0,zero
 move	sp,s8
 lw	ra,44(sp)
 lw	s8,40(sp)
 addiu	sp,sp,48
 jr	ra
 nop
 ...