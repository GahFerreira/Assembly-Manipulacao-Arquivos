.equ STDIN, 0 			# standard input
.equ STDOUT, 1 			# standard output

.equ SYS_read, 0 		# read
.equ SYS_write, 1 		# write
.equ SYS_open, 2 		# file open
.equ SYS_close, 3 		# file close
.equ SYS_creat, 85 		# file open/create

.equ O_RDONLY, 0			# read only
.equ O_WDONLY, 1			# write only
.equ O_RDWR, 2			# read and write

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

.equ END_OF_STRING, 0
.equ PERCENT, 37
.equ LETTER_S, 115
.equ LETTER_L, 108
.equ LETTER_D, 100
.equ LETTER_C, 99

.section .data
	enterMsgString: .string "Enter a String: "
	input_file: 	.string "input.txt"
	teste: .string "tesfl"

.section .bss
.lcomm line, STRLEN_LINE

.section .text
.globl _start

fopen_SB:
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

movq 	$SYS_open, %rax 	# file open/create
movq 	$input_file, %rdi
movq 	$O_CREAT, %rsi
orq 	$O_WDONLY, %rsi		# write
movq	$S_MODE, %rdx
syscall # return file descriptor in %rax

movq  	%rax, %rdi			# file descriptor
movq 	$SYS_write, %rax	# system code for write()
movq 	$line, %rsi			# string address
movq 	$STRLEN_LINE, %rdx	# length value
syscall

popq 	%rbp
ret

fclose_SB:
pushq %rbp

movq $SYS_close, %rax
movq %rdi, %rdi
syscall

popq %rbp
ret

# %rdi : file descriptor
# %rsi : endereço da string na pilha
# ... : 0..* variáveis na pilha
fprintf:
	pushq %rbp
	movq %rsp, %rbp

	# %rax guarda posição atual da string
	movq $0, %rax

	# numero de porcentagens na string
	movq $0, %rcx

	
	# enquanto nao for fim do vetor
	condicao_1_fprintf:
		movb (%rsi, %rax, 1), %bl
		cmpb $END_OF_STRING, %bl # Checa se terminou a string
		je fim_while_1_fprintf

		#	verifica posicaoatual se é porcentagem
		# 	se for porcentagem
		cmpb $PERCENT, %bl
		jne fim_if_1
			# incrementa posicao atual
			incq %rax

			# verifica qual o caractere após a porcentagem
			movb (%rsi, %rax, 1), %bl

			# salta para rotulo especifico para tratar esse caractere
			# %s
			cmpb $LETTER_S, %bl
			jne rotulo_ld
			# call 

			# %ld
			rotulo_ld:
			cmpb $LETTER_L, %bl
			incq %rax # vai para o 'd' do 'ld' (possivelmente há tratamento de erro para %l)
			jne rotulo_c
			# call

			# %c
			rotulo_c:
			cmpb $LETTER_C, %bl
			jne rotulo_fim_switch
			# call
			
			rotulo_fim_switch:

			incq %rcx # Quantos caracteres (temporário)

		fim_if_1:

	

	
	
	# 	se nao for porcentagem
	# 		imprime o caractere na saida
	# 	incrementa posicao atual
		incq %rax
	
		# jne inicio_while_1_fprintf
	# termina
		jmp condicao_1_fprintf
	fim_while_1_fprintf:
	# movsbq %bl, %rax
	popq %rbp
	ret

_start:
pushq %rbp
movq %rsp, %rbp

# call fopen_SB
# call fclose_SB

movq $teste, %rsi

call fprintf
movq %rax, %rdi

popq %rbp

movq 	$SYS_exit, %rax
movq $60, %rax
syscall
