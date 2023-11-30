.equ STDIN, 0 			# standard input
.equ STDOUT, 1 			# standard output

.equ SYS_read, 0 		# read
.equ SYS_write, 1 		# write
.equ SYS_open,2 		# file open
.equ SYS_close,3 		# file close
.equ SYS_creat,85 		# file open/create

.equ O_RDONLY,0			# read only
.equ O_WDONLY,1			# write only
.equ O_RDWR,2			# read and write

.equ O_CREAT, 0100		
.equ O_TRUNC, 01000
.equ O_APPEND, 02000

.equ S_IWUSR, 0200		#proprietário, permissão para escrita
.equ S_IRUSR, 0400		#proprietário, permissão para leitura
.equ S_IXUSR, 0100		#proprietário, permissão para execução
.equ S_MODE,  0700

.equ SYS_exit, 60 		# terminate

.equ STRLEN_LINE, 11
.equ STRLEN_OUPUT, 17

.section .data
	enterMsgString: .string "Enter a String: "
	input_file: 	.string "input.txt"

.section .bss
.lcomm line, STRLEN_LINE

.section .text
.globl _start

_start:
	pushq	%rbp
	movq	%rsp, %rbp
	
	movq $SYS_write, %rax		# system code for write()
	movq $STDOUT, %rdi			# standard output 		
	movq $enterMsgString, %rsi  # string address
	movq $STRLEN_OUPUT, %rdx	# length value
	syscall
	
	movq $SYS_read, %rax		# system code for read()
	movq $STDIN, %rdi			# standard input
	movq $line, %rsi   			# string address
	movq $STRLEN_LINE, %rdx		# length value
	syscall
	
	movq $SYS_write, %rax		# system code for write()
	movq $STDOUT, %rdi			# standard output
	movq $line, %rsi			# string address
	movq $STRLEN_LINE, %rdx		# length value
	syscall
	
	movq 	$SYS_open, %rax 			# file open/create
	movq 	$input_file, %rdi
	movq 	$O_CREAT, %rsi
	orq 	$O_WDONLY, %rsi				# write
	movq	$S_MODE, %rdx
	syscall # return file descriptor in %rax

	movq  	%rax, %rdi			# file descriptor
	movq 	$SYS_write, %rax	# system code for write()
	movq 	$line, %rsi			# string address
	movq 	$STRLEN_LINE, %rdx	# length value
	syscall

	movq $SYS_close, %rax
	movq %rdi, %rdi
	syscall

	popq 	%rbp
	movq 	$SYS_exit, %rax
	syscall
