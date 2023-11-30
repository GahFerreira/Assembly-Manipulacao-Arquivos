.section .data
	str1: .string "%s "
	str2: .string "------"
	caractere: .byte 0
	# Constantes
	.equ STDOUT, 1 			# standard output
	.equ READ_SERVICE, 0
	.equ SYS_WRITE, 1 
	.equ OPEN_SERVICE, 2
	.equ CLOSE_SERVICE, 3
	.equ EXIT_SERVICE, 60
	.equ O_RDONLY, 0000
	.equ O_CREAT, 0100
	.equ O_WRONLY, 0001
	.equ MODE, 0666

.section .bss
	.equ TAM_BUFFER, 10
	.lcomm BUFFER, TAM_BUFFER

.section .text
.globl main
main:

	pushq %rbp
	movq %rsp, %rbp
	subq $64, %rsp
	movq $0, -64(%rbp)

	# Salva parâmetros argc, argv, arge
	movq %rdi, -40(%rbp) # salva argc em-40(%rbp)
	movq %rsi, -48(%rbp) # salva argv em -48(%rbp)
	movq %rdx, -56(%rbp) # salva arge em -56(%rbp)

	# Cria fd para fd_read
	movq $OPEN_SERVICE, %rax	
	movq -48(%rbp), %rbx
	movq 8(%rbx), %rdi
	movq $O_RDONLY, %rsi
	movq $MODE, %rdx
	syscall
	# -8(%rbp) recebe descritor
	movq %rax, -8(%rbp)
	
	movq $0, %rbx
_while:	
	# nova leitura
	movq $READ_SERVICE, %rax
	movq -8(%rbp), %rdi
	movq $caractere, %rsi
	movq $1, %rdx
	syscall
	movq %rax, -24(%rbp)
	cmpq $0, -24(%rbp)
	jle fim_programa
		movq $BUFFER, %rcx
		addq %rbx, %rcx
		movb caractere, %al 
		movb %al, (%rcx)
		incq %rbx
	cmpb $10,caractere
	je _if
	jmp _while
	_if:
	  	movq $BUFFER, %rcx #colocando \0 no BUFFER
		addq %rbx, %rcx
		movb $0, %al 
		movb %al, (%rcx)
		
		movq $SYS_WRITE, %rax # imprime numero separado por \n
		movq $STDOUT, %rdi
		movq $BUFFER, %rsi
		movq %rbx, %rdx
		syscall
		
		movq $0, %rbx
	jmp _while
	
	fim_programa:
		movq $BUFFER, %rcx #colocando \0 no BUFFER
		addq %rbx, %rcx
		movb $0, %al 
		movb %al, (%rcx)
		
		movq $SYS_WRITE, %rax # imprime numero separado por \n
		movq $STDOUT, %rdi
		movq $BUFFER, %rsi
		movq %rbx, %rdx
		syscall
		
	movq $CLOSE_SERVICE, %rax
	movq -8(%rbp), %rdi
	syscall
	
	movq -64(%rbp), %rdi
	movq $EXIT_SERVICE, %rax
	syscall
