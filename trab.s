.equ STDIN, 0 			# standard input
.equ STDOUT, 1 			# standard output

.equ SYS_read, 0 		# read
.equ SYS_write, 1 		# write
.equ SYS_open, 2 		# file open
.equ SYS_close, 3 		# file close
.equ SYS_creat, 85 		# file open/create

.equ O_RDONLY, 0		# read only
.equ O_WDONLY, 1		# write only
.equ O_RDWR, 2			# read and write

.equ O_CREAT, 0100		
.equ O_TRUNC, 01000
.equ O_APPEND, 02000

.equ S_IWUSR, 0200		# proprietário, permissão para escrita
.equ S_IRUSR, 0400		# proprietário, permissão para leitura
.equ S_IXUSR, 0100		# proprietário, permissão para execução
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
	# enterMsgString: .string "Enter a String: "
	input_file: 	.string "input.txt"
	teste0: .string "Tesfl0"
	teste1: .string "Tesfl1"
	teste2: .string "Tesfl2"
	teste3: .string "Tesfl3"
	teste4: .string "Tesfl4"
	teste5: .string "Tesfl5"
	teste6: .string "Tesfl6"
	teste7: .quad 888
	parametros: .string "%s%s%s%s%s%s%s%ld"
# .section .bss
# .lcomm line, STRLEN_LINE

.section .text
.globl _start

# fopen_SB:
# pushq	%rbp
# movq	%rsp, %rbp

# movq $SYS_write, %rax		# system code for write()
# movq $STDOUT, %rdi			# standard output 		
# movq $enterMsgString, %rsi  # string address
# movq $STRLEN_OUPUT, %rdx	# length value
# syscall

# movq $SYS_read, %rax		# system code for read()
# movq $STDIN, %rdi			# stanFstadard input
# movq $line, %rsi   			# string address
# movq $STRLEN_LINE, %rdx		# length value
# syscall

# movq $SYS_write, %rax		# system code for write()
# movq $STDOUT, %rdi			# standard output
# movq $line, %rsi			# string address
# movq $STRLEN_LINE, %rdx		# length value
# syscall

# movq 	$SYS_open, %rax 	# file open/create
# movq 	$input_file, %rdi
# movq 	$O_CREAT, %rsi
# orq 	$O_WDONLY, %rsi		# write
# movq	$S_MODE, %rdx
# syscall # return file descriptor in %rax

# movq  	%rax, %rdi			# file descriptor
# movq 	$SYS_write, %rax	# system code for write()
# movq 	$line, %rsi			# string address
# movq 	$STRLEN_LINE, %rdx	# length value
# syscall

# popq 	%rbp
# ret

fclose_SB:
pushq %rbp
movq %rsp, %rbp

movq $SYS_close, %rax
movq %rdi, %rdi
syscall

popq %rbp
ret

fopen_SB:
pushq %rbp
movq %rsp, %rbp

# movq 	$SYS_open, %rax 	# file open/create
# movq 	$input_file, %rdi
# movq 	$O_CREAT, %rsi
# orq 	$O_WDONLY, %rsi		# write
# movq	$S_MODE, %rdx
# syscall # return file descriptor in %rax

movq 	$SYS_open, %rax 	# file open/create
leaq 	input_file(%rip), %rdi
movq 	$O_CREAT, %rsi
orq 	$O_WDONLY, %rsi		# write
movq	$S_MODE, %rdx
syscall # return file descriptor in %rax

popq %rbp
ret

# fprintf(ARQUIVO, "%s textoaleatorio %s%s%s%s%s", a, b, c, d, e, f);
# %rdi = ARQUIVO
# %rsi = "%s textoaleatorio %s%s%s%s%s"
# %rdx, %rcx, %r8, %r9 = a, b, c, d
# pilha = e, f
fprintf:
	pushq %rbp
	movq %rsp, %rbp

	# %rax guarda posição atual da string
	movq $0, %rax

	# número de porcentagens na string
	movq $0, %r11

	# enquanto não for fim do vetor
	fprintf_condicao_1:
		movb (%rsi, %rax, 1), %bl
		cmpb $END_OF_STRING, %bl # Checa se terminou a string
		je fprintf_fim_while_1

		# verifica posicaoatual se é porcentagem
		# se for porcentagem
		cmpb $PERCENT, %bl
		jne fim_if_1
			# incrementa posicão atual
			incq %rax

			# verifica qual o caractere após a porcentagem
			movb (%rsi, %rax, 1), %bl

			# Sobrescreve %r12 com o endereço da variável cujo índice é o índice da porcentagem atual
			fprintf_reg_1:
				cmpq $0, %r11
				jne fprintf_reg_2
				movq %rdx, %r12
				jmp fprintf_fim_regs

			fprintf_reg_2:
				cmpq $1, %r11
				jne fprintf_reg_3
				movq %rcx, %r12
				jmp fprintf_fim_regs

			fprintf_reg_3:
				cmpq $2, %r11
				jne fprintf_reg_4
				movq %r8, %r12
				jmp fprintf_fim_regs

			fprintf_reg_4:
				cmpq $3, %r11
				jne fprintf_pilha
				movq %r9, %r12
				jmp fprintf_fim_regs

			fprintf_pilha:
				subq $2, %r11
				movq (%rbp, %r11, 8), %r12
				addq $2, %r11

			fprintf_fim_regs:
# %s /////////////////////////////////////////////////////////////////////////////// 
			# salta para rotulo especifico para tratar esse caractere %s
			cmpb $LETTER_S, %bl
			jne rotulo_ld

			pushq %rax
			pushq %rdi
			pushq %rsi
			pushq %rdx
			pushq %rcx
			pushq %r8
			pushq %r9
			pushq %r11

			movq $0, %rdx

			# contar tamanho da string
			fprintf_condicao_2:
				movb (%r12, %rdx, 1), %al
				cmpb $END_OF_STRING, %al # Checa se terminou a string
				je fprintf_fim_while_2
				incq %rdx
				jmp fprintf_condicao_2
			fprintf_fim_while_2:
			
			movq $SYS_write, %rax		# system code for write()
			# movq $STDOUT, %rdi		# standard output [%rdi já possui o endereço do arquivo]
			movq %r12, %rsi  			# string address
			# movq $STRLEN_OUPUT, %rdx	# length value [%rdx já possui a 'length']
			syscall

			popq %r11
			popq %r9
			popq %r8
			popq %rcx
			popq %rdx
			popq %rsi
			popq %rdi
			popq %rax

			jmp rotulo_fim_switch

# %ld /////////////////////////////////////////////////////////////////////////////// 
			rotulo_ld:
			cmpb $LETTER_L, %bl
			jne rotulo_c
			incq %rax # vai para o 'd' do 'ld' (possivelmente há tratamento de erro para %l)
			
			pushq %rax
			pushq %rdi
			pushq %rsi
			pushq %rdx
			pushq %rcx
			pushq %r8
			pushq %r9
			pushq %r11

			movq $8, %rdx

			# contar tamanho da string
			# fprintf_condicao_2:
			# 	movb (%r12, %rdx, 1), %al
			# 	cmpb $END_OF_STRING, %al # Checa se terminou a string
			# 	je fprintf_fim_while_2
			# 	incq %rdx
			# 	jmp fprintf_condicao_2
			# fprintf_fim_while_2:
			
			movq $SYS_write, %rax		# system code for write()
			# movq $STDOUT, %rdi		# standard output [%rdi já possui o endereço do arquivo]
			movq %r12, %rsi  			# string address
			# movq $STRLEN_OUPUT, %rdx	# length value [%rdx já possui a 'length']
			syscall

			popq %r11
			popq %r9
			popq %r8
			popq %rcx
			popq %rdx
			popq %rsi
			popq %rdi
			popq %rax

			jmp rotulo_fim_switch

# %c /////////////////////////////////////////////////////////////////////////////// 
			rotulo_c:
			cmpb $LETTER_C, %bl
			jne rotulo_fim_switch
			# call
			
			rotulo_fim_switch:
			incq %r11

		fim_if_1:

	# se nao for porcentagem
	# imprime o caractere na saida
	# incrementa posicao atual
		incq %rax

		jmp fprintf_condicao_1
	fprintf_fim_while_1:
	
	# movq %r11, %rax

	popq %rbp
	ret

_start:
pushq %rbp
movq %rsp, %rbp

call fopen_SB
# call fclose_SB
subq $32, %rsp

movq %rax, %rdi
leaq parametros(%rip), %rsi

leaq teste0(%rip), %rdx
leaq teste1(%rip), %rcx
leaq teste2(%rip), %r8
leaq teste3(%rip), %r9
movq $teste4, -8(%rbp)
movq $teste5, -16(%rbp)
movq $teste6, -24(%rbp)
movq teste7, %rbx
movq %rbx, -32(%rbp)

# empilhar ao contrario os parametros da pilha
pushq -32(%rbp)
pushq -24(%rbp)
pushq -16(%rbp)
pushq -8(%rbp)

call fprintf
movq %rax, %rdi

popq -8(%rbp)
popq -16(%rbp)
popq -24(%rbp)
popq -32(%rbp)

addq $16, %rsp
popq %rbp

# fprintf(ARQUIVO, "%s%s%s%s%s%s", a, b, c, d, e, f);

# %rdi = ARQUIVO
# %rsi = "%s%s%s%s%s%s"
# %rdx, %rcx, %r8, %r9 = a, b, c, d,
# pilha = e, f

movq $SYS_exit, %rax
movq $60, %rax
syscall
