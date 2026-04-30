	.file	"main.c"
	.text
	.def	__main;	.scl	2;	.type	32;	.endef
	.section .rdata,"dr"
.LC0:
	.ascii "%d\12\0"
	.text
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$48, %rsp
	.seh_stackalloc	48
	.seh_endprologue
	call	__main
	movl	$15, -16(%rbp)
	movl	$0, -4(%rbp)
	movl	$1, -8(%rbp)
	jmp	.L2
.L6:
	movl	-16(%rbp), %eax
	movl	%eax, -12(%rbp)
	jmp	.L3
.L4:
	movl	-8(%rbp), %eax
	subl	%eax, -12(%rbp)
.L3:
	movl	-12(%rbp), %eax
	cmpl	-8(%rbp), %eax
	jge	.L4
	cmpl	$0, -12(%rbp)
	jne	.L5
	movl	-8(%rbp), %eax
	addl	%eax, -4(%rbp)
.L5:
	addl	$1, -8(%rbp)
.L2:
	movl	-8(%rbp), %eax
	cmpl	-16(%rbp), %eax
	jle	.L6
	movl	-4(%rbp), %eax
	movl	%eax, %edx
	leaq	.LC0(%rip), %rax
	movq	%rax, %rcx
	call	printf
	movl	$0, %eax
	addq	$48, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.ident	"GCC: (MinGW-W64 x86_64-ucrt-posix-seh, built by Brecht Sanders) 12.2.0"
	.def	printf;	.scl	2;	.type	32;	.endef
