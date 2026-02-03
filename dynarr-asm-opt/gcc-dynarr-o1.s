	.file	"dynarr.c"
	.intel_syntax noprefix
	.text
	.globl	init
	.type	init, @function
init:
	mov	ecx, -1
	cmp	QWORD PTR [rdi], 0
	jne	.L10
	push	r12
	push	rbp
	push	rbx
	mov	r12, rdi
	mov	rbx, rsi
	mov	rbp, rdx
	test	rsi, rsi
	je	.L6
	test	rdx, rdx
	je	.L6
	mov	ecx, -3
	mov	rax, rsi
	mul	rbp
	jo	.L1
	mov	rdi, rax
	call	malloc@PLT
	test	rax, rax
	je	.L8
	mov	QWORD PTR [r12], rax
	mov	QWORD PTR 8[r12], rbx
	mov	QWORD PTR 24[r12], rbp
	mov	QWORD PTR 16[r12], 0
	mov	ecx, 0
.L1:
	mov	eax, ecx
	pop	rbx
	pop	rbp
	pop	r12
	ret
.L6:
	mov	ecx, -2
	jmp	.L1
.L8:
	mov	ecx, -4
	jmp	.L1
.L10:
	mov	eax, ecx
	ret
	.size	init, .-init
	.globl	extend
	.type	extend, @function
extend:
	test	rdi, rdi
	je	.L16
	push	rbp
	push	rbx
	sub	rsp, 8
	mov	rbp, rdi
	mov	rdi, QWORD PTR [rdi]
	test	rdi, rdi
	je	.L17
	add	rsi, QWORD PTR 16[rbp]
	mov	rbx, QWORD PTR 24[rbp]
	mov	eax, 0
	cmp	rbx, rsi
	jnb	.L13
	.p2align 3
.L15:
	add	rbx, rbx
	cmp	rbx, rsi
	jb	.L15
	mov	rsi, rbx
	imul	rsi, QWORD PTR 8[rbp]
	call	realloc@PLT
	test	rax, rax
	je	.L19
	mov	QWORD PTR 0[rbp], rax
	mov	QWORD PTR 24[rbp], rbx
	mov	eax, 0
.L13:
	add	rsp, 8
	pop	rbx
	pop	rbp
	ret
.L16:
	mov	eax, -5
	ret
.L17:
	mov	eax, -5
	jmp	.L13
.L19:
	mov	eax, -6
	jmp	.L13
	.size	extend, .-extend
	.globl	pushOne
	.type	pushOne, @function
pushOne:
	push	r12
	push	rbp
	push	rbx
	test	rdi, rdi
	je	.L27
	mov	rbx, rdi
	mov	rbp, rsi
	cmp	QWORD PTR [rdi], 0
	je	.L28
	test	rsi, rsi
	je	.L29
	mov	esi, 1
	call	extend
	mov	r12d, eax
	test	eax, eax
	je	.L31
.L25:
	mov	eax, r12d
	pop	rbx
	pop	rbp
	pop	r12
	ret
.L31:
	mov	rdx, QWORD PTR 8[rbx]
	mov	rdi, rdx
	imul	rdi, QWORD PTR 16[rbx]
	add	rdi, QWORD PTR [rbx]
	mov	rsi, rbp
	call	memcpy@PLT
	add	QWORD PTR 16[rbx], 1
	jmp	.L25
.L27:
	mov	r12d, -5
	jmp	.L25
.L28:
	mov	r12d, -5
	jmp	.L25
.L29:
	mov	r12d, -7
	jmp	.L25
	.size	pushOne, .-pushOne
	.globl	pushMany
	.type	pushMany, @function
pushMany:
	push	r13
	push	r12
	push	rbp
	push	rbx
	sub	rsp, 8
	test	rdi, rdi
	je	.L34
	mov	rbx, rdi
	mov	r13, rsi
	mov	rbp, rdx
	cmp	QWORD PTR [rdi], 0
	je	.L35
	test	rsi, rsi
	je	.L36
	test	rdx, rdx
	je	.L36
	mov	rsi, rdx
	call	extend
	mov	r12d, eax
	test	eax, eax
	jne	.L32
	mov	rdx, QWORD PTR 8[rbx]
	mov	rdi, rdx
	imul	rdi, QWORD PTR 16[rbx]
	add	rdi, QWORD PTR [rbx]
	imul	rdx, rbp
	mov	rsi, r13
	call	memcpy@PLT
	add	QWORD PTR 16[rbx], rbp
	jmp	.L32
.L34:
	mov	r12d, -5
	jmp	.L32
.L35:
	mov	r12d, -5
	jmp	.L32
.L36:
	mov	r12d, -7
.L32:
	mov	eax, r12d
	add	rsp, 8
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	ret
	.size	pushMany, .-pushMany
	.globl	boundcheck
	.type	boundcheck, @function
boundcheck:
	cmp	rdx, rdi
	setnb	cl
	cmp	rdx, rsi
	setb	al
	movzx	eax, al
	and	eax, ecx
	ret
	.size	boundcheck, .-boundcheck
	.globl	getelement
	.type	getelement, @function
getelement:
	test	rdi, rdi
	je	.L41
	mov	rax, QWORD PTR [rdi]
	test	rax, rax
	je	.L39
	cmp	rsi, QWORD PTR 16[rdi]
	jnb	.L42
	imul	rsi, QWORD PTR 8[rdi]
	add	rax, rsi
	ret
.L41:
	mov	rax, rdi
	ret
.L42:
	mov	eax, 0
.L39:
	ret
	.size	getelement, .-getelement
	.globl	isempty
	.type	isempty, @function
isempty:
	cmp	QWORD PTR 16[rdi], 0
	setne	al
	movzx	eax, al
	ret
	.size	isempty, .-isempty
	.globl	setidx
	.type	setidx, @function
setidx:
	test	rdi, rdi
	je	.L46
	mov	rax, QWORD PTR [rdi]
	test	rax, rax
	je	.L47
	test	rsi, rsi
	je	.L48
	mov	ecx, -8
	cmp	rdx, QWORD PTR 16[rdi]
	jb	.L54
.L51:
	mov	eax, ecx
	ret
.L54:
	sub	rsp, 8
	mov	rcx, QWORD PTR 8[rdi]
	imul	rdx, rcx
	lea	rdi, [rax+rdx]
	mov	rdx, rcx
	call	memcpy@PLT
	mov	ecx, 0
	mov	eax, ecx
	add	rsp, 8
	ret
.L46:
	mov	ecx, -5
	jmp	.L51
.L47:
	mov	ecx, -5
	jmp	.L51
.L48:
	mov	ecx, -7
	jmp	.L51
	.size	setidx, .-setidx
	.globl	mergedyn2dyn
	.type	mergedyn2dyn, @function
mergedyn2dyn:
	push	r12
	push	rbp
	push	rbx
	test	rdi, rdi
	je	.L57
	mov	rbx, rdi
	mov	rbp, rsi
	cmp	QWORD PTR [rdi], 0
	je	.L58
	test	rsi, rsi
	je	.L58
	cmp	QWORD PTR [rsi], 0
	je	.L59
	mov	r12d, -9
	mov	rax, QWORD PTR 8[rsi]
	cmp	QWORD PTR 8[rdi], rax
	je	.L62
.L55:
	mov	eax, r12d
	pop	rbx
	pop	rbp
	pop	r12
	ret
.L62:
	mov	rsi, QWORD PTR 16[rdi]
	mov	rdi, rbp
	call	extend
	mov	r12d, eax
	test	eax, eax
	jne	.L55
	mov	rdi, QWORD PTR 16[rbp]
	imul	rdi, QWORD PTR 8[rbp]
	add	rdi, QWORD PTR 0[rbp]
	mov	rdx, QWORD PTR 16[rbx]
	imul	rdx, QWORD PTR 8[rbx]
	mov	rsi, QWORD PTR [rbx]
	call	memcpy@PLT
	mov	rax, QWORD PTR 16[rbx]
	add	QWORD PTR 16[rbp], rax
	jmp	.L55
.L57:
	mov	r12d, -5
	jmp	.L55
.L58:
	mov	r12d, -5
	jmp	.L55
.L59:
	mov	r12d, -5
	jmp	.L55
	.size	mergedyn2dyn, .-mergedyn2dyn
	.globl	export2stack
	.type	export2stack, @function
export2stack:
	mov	rax, rdi
	test	rdi, rdi
	je	.L65
	mov	rdi, rsi
	mov	rsi, QWORD PTR [rax]
	test	rsi, rsi
	je	.L66
	sub	rsp, 8
	mov	rdx, QWORD PTR 16[rax]
	imul	rdx, QWORD PTR 8[rax]
	call	memcpy@PLT
	mov	eax, 0
	add	rsp, 8
	ret
.L65:
	mov	eax, -5
	ret
.L66:
	mov	eax, -5
	ret
	.size	export2stack, .-export2stack
	.globl	insertidx
	.type	insertidx, @function
insertidx:
	test	rdi, rdi
	je	.L73
	push	r12
	push	rbp
	push	rbx
	mov	rbx, rdi
	mov	r12, rsi
	mov	rbp, rdx
	cmp	QWORD PTR [rdi], 0
	je	.L74
	test	rsi, rsi
	je	.L75
	mov	eax, -8
	cmp	rdx, QWORD PTR 16[rdi]
	jb	.L81
.L71:
	pop	rbx
	pop	rbp
	pop	r12
	ret
.L81:
	mov	esi, 1
	call	extend
	test	eax, eax
	jne	.L71
	mov	rdi, QWORD PTR [rbx]
	mov	rcx, QWORD PTR 8[rbx]
	lea	rax, 1[rbp]
	imul	rax, rcx
	mov	rdx, QWORD PTR 16[rbx]
	sub	rdx, rbp
	imul	rdx, rcx
	mov	rsi, rax
	sub	rsi, rcx
	add	rsi, rdi
	add	rdi, rax
	call	memmove@PLT
	mov	rdx, rbp
	mov	rsi, r12
	mov	rdi, rbx
	call	setidx
	test	eax, eax
	jne	.L71
	add	QWORD PTR 16[rbx], 1
	jmp	.L71
.L73:
	mov	eax, -5
	ret
.L74:
	mov	eax, -5
	jmp	.L71
.L75:
	mov	eax, -7
	jmp	.L71
	.size	insertidx, .-insertidx
	.globl	removeidx
	.type	removeidx, @function
removeidx:
	test	rdi, rdi
	je	.L84
	push	rbx
	mov	rbx, rdi
	mov	rdi, QWORD PTR [rdi]
	test	rdi, rdi
	je	.L85
	mov	rdx, QWORD PTR 16[rbx]
	mov	eax, -8
	cmp	rsi, rdx
	jb	.L91
.L82:
	pop	rbx
	ret
.L91:
	mov	rax, QWORD PTR 8[rbx]
	mov	rcx, rax
	imul	rcx, rsi
	sub	rdx, rsi
	sub	rdx, 1
	imul	rdx, rax
	lea	rsi, [rax+rcx]
	add	rsi, rdi
	add	rdi, rcx
	call	memmove@PLT
	sub	QWORD PTR 16[rbx], 1
	mov	eax, 0
	jmp	.L82
.L84:
	mov	eax, -5
	ret
.L85:
	mov	eax, -5
	jmp	.L82
	.size	removeidx, .-removeidx
	.globl	clearArr
	.type	clearArr, @function
clearArr:
	test	rdi, rdi
	je	.L94
	cmp	QWORD PTR [rdi], 0
	je	.L95
	mov	QWORD PTR [rdi], 0
	mov	QWORD PTR 16[rdi], 0
	mov	QWORD PTR 8[rdi], 0
	mov	eax, 0
	ret
.L94:
	mov	eax, -5
	ret
.L95:
	mov	eax, -5
	ret
	.size	clearArr, .-clearArr
	.globl	freeArr
	.type	freeArr, @function
freeArr:
	test	rdi, rdi
	je	.L98
	push	rbx
	mov	rbx, rdi
	mov	eax, -5
	cmp	QWORD PTR 24[rdi], 0
	je	.L96
	mov	rdi, QWORD PTR [rdi]
	call	free@PLT
	mov	QWORD PTR [rbx], 0
	mov	QWORD PTR 24[rbx], 0
	mov	QWORD PTR 16[rbx], 0
	mov	QWORD PTR 8[rbx], 0
	mov	eax, 0
.L96:
	pop	rbx
	ret
.L98:
	mov	eax, -5
	ret
	.size	freeArr, .-freeArr
	.ident	"GCC: (Debian 14.2.0-19) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
