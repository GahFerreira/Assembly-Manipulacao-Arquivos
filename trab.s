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
	parametrofopen: .string "w" # parametros implementados = w+(leitura e escrita), w(somente escrita), r(somente leitura)
	output_file: .string "output.txt"
	teste0: .string "Tesfl0"
	teste1: .string "Tesfl1"
	teste2: .string "Tesfl2"
	teste3: .string "Tesfl3"
	teste4: .string "Tesfl4"
	teste5: .string "Tesfl5"
	teste6: .string "Tesfl6"
	teste7inteiro: .quad -00000000
	teste8inteiro: .quad 999
	teste8char: .byte '*'
	teste9char: .byte '*'
	teste10char: .byte '*'
	teste11char: .byte '*'
	parametros: .string "FUNCIONA:%sSera?%sMesmo?%s %s funciona %s sim %s HA%s H A %ld H A A %c HA A A A %c aÇaí %c é mUITO %c BOM %ld KKK"
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
# movq 	$output_file, %rdi
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
converter_inteiro_em_string:
pushq %rbp
movq %rsp, %rbp
	leaq 16(%rbp), %r12  # acessa endereço da string

	# move o valor inteiro pra rax
	movq %rdi, %rax
	movq $10, %rbx

	cmpq $0, %rax		# se for negativo torna positivo para evitar erros
	jge proximo_digito
	negq %rax

		proximo_digito:
			movq $0, %rdx
			divq %rbx
			addb $48, %dl
			decq %rsi
			movb %dl, (%r12, %rsi, 1)
			cmpq $0,%rax
			jne proximo_digito

		movq $0, %rdx
		movb $0, %dl

		cmpq $0, %rdi 	# caso numero negativo coloca sinal negativo
		jge nao_necessario_adicionar_negativo
		addb $45, %dl
		decq %rsi
		movb %dl, (%r12, %rsi, 1)

		nao_necessario_adicionar_negativo:

popq %rbp
ret

checar_tamanho_inteiro:
pushq %rbp
movq %rsp, %rbp
	# move o valor inteiro pra rax
	movq %rdi, %rax
	# contador de digitos
	movq $1, %r15 # comeca com 1 pois adicionar byte do \0
	movq $10, %rbx

		cmpq $0, %rax 	# caso numero negativo incrementa 1 no contador para sinal de negativo
		jge menor_que_10
		incq %r15
		negq %rax

		menor_que_10:
		cmp $9, %rax
		jle fim_if_conversao
		incq %r15

		divq %rbx
		movq $0, %rdx
		
		jmp menor_que_10
		fim_if_conversao:

	movq %r15, %rax
popq %rbp
ret

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

	movq $0, %r13
	movb (%rdi, %r13,1), %al

	cmpb $114, %al # parametro = r(114)
	jne parametro_wplus

		# movq 	$SYS_open, %rax 	# file open/create
		# leaq 	output_file(%rip), %rdi
		movq 	$O_RDONLY, %rsi
		# orq 	$O_WDONLY, %rsi		# write
		movq	$S_MODE, %rdx
		syscall # return file descriptor in %rax

	jmp fim_fopen

	parametro_wplus:
	movq $1, %r13
	movb (%rdi, %r13,1), %al

	cmpb $43, %al	# parametro = +(43)(w+)
	jne parametro_w

		movq 	$SYS_open, %rax 	# file open/create
		leaq 	output_file(%rip), %rdi
		movq 	$O_CREAT, %rsi
		orq 	$O_RDWR, %rsi		# write
		movq	$S_MODE, %rdx
		syscall # return file descriptor in %rax

	jmp fim_fopen

	parametro_w:
	movq $0, %r13
	movb (%rdi, %r13,1), %al

	cmpb $119, %al	# parametro = w(119)
	jne fim_fopen

		movq 	$SYS_open, %rax 	# file open/create
		leaq 	output_file(%rip), %rdi
		movq 	$O_CREAT, %rsi
		orq 	$O_WDONLY, %rsi		# write
		movq	$S_MODE, %rdx
		syscall # return file descriptor in %rax

	jmp fim_fopen

	fim_fopen:
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
			rotulo_s:
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
			# movq $STRLEN_OUPUT, %rdx	# length size [%rdx já possui a 'length']
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
			pushq %rdx
			pushq %rcx
			pushq %r8
			pushq %r9
			pushq %r11
			pushq %rsi
			pushq %rdi

			movq $0, %rdx
			
			movq %r12,%rdi
			call checar_tamanho_inteiro
			movq %rax, %r14

			# parametros para a funcao converter inteiro
			movq %r12, %rdi # numero inteiro a ser transformado
			movq %r14, %rsi	# tamanho do numero inteiro

			subq $24, %rsp  # memoria alocada p/ endereço da string(numero maximo de digitos de um inteiro e 20 + \0, porem deve ser multiplo de 8 o valor)
			call converter_inteiro_em_string
			addq $24, %rsp # desloca o ponteiro para conseguir desempilhar os parametros

			popq %rdi
			popq %rsi
			
			# após salvar os registradores antes do syscall
			pushq %rsi
			pushq %rdi
			subq $24, %rsp # direciona o ponteiro novamente após salvar os registradores antes do syscall
			movq $SYS_write, %rax		# system code for write()
			# movq $STDOUT, %rdi		# standard output [%rdi já possui o endereço do arquivo]
			leaq -88(%rbp), %rsi  		# Endereco da string na pilha(Topo da pilha possuiu o algarismo mais significativo)
			movq %r14, %rdx	            # length size
			addq $24, %rsp # desloca o ponteiro novamente antes do syscall(pois da B.O se for depois :0)
			syscall

			popq %rdi
			popq %rsi
			popq %r11
			popq %r9
			popq %r8
			popq %rcx
			popq %rdx
			popq %rax

			jmp rotulo_fim_switch
# %c /////////////////////////////////////////////////////////////////////////////// 
			rotulo_c:
			cmpb $LETTER_C, %bl
			jne rotulo_fim_switch

			pushq %rax
			pushq %rdi
			pushq %rsi
			pushq %rdx
			pushq %rcx
			pushq %r8
			pushq %r9
			pushq %r11

			movq $0, %rdx

			movb (%r12, %rdx, 1), %al
			movq $SYS_write, %rax		# system code for write()
			# movq $STDOUT, %rdi		# standard output [%rdi já possui o endereço do arquivo]
			movq %r12, %rsi  			# string address
			movq $1, %rdx	# length size
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
# fim escolhas para % ///////////////////////////////////////////////////
			rotulo_fim_switch:
			# incrementa numero de porcentagens
			incq %r11
			# incrementa posicao atual
			incq %rax
			jmp fprintf_condicao_1
		fim_if_1:

	# se nao for porcentagem imprime o caractere na saida
		pushq %rax
		pushq %rdi
		pushq %rsi
		pushq %rdx
		pushq %rcx
		pushq %r8
		pushq %r9
		pushq %r11
		
		movq %rax, %r8
		movq $SYS_write, %rax		# system code for write()
		# movq $STDOUT, %rdi		# standard output [%rdi já possui o endereço do arquivo]
		leaq (%rsi, %r8, 1), %rsi	# string address[ja em %rsi]
		movq $1, %rdx				# length size
		syscall

		popq %r11
		popq %r9
		popq %r8
		popq %rcx
		popq %rdx
		popq %rsi
		popq %rdi
		popq %rax

		# incrementa posicao atual
		incq %rax

		jmp fprintf_condicao_1
	fprintf_fim_while_1:
	
	popq %rbp
	ret

_start:
pushq %rbp
movq %rsp, %rbp

movq $parametrofopen, %rdi
call fopen_SB

movq %rax, %rdi
# parametros("%s%s%s%s%s%s%s%ld%c%c%c%c%ld"):
leaq parametros(%rip), %rsi

subq $72, %rsp
# variaveis(necessario estar em ordem com os parametros):
leaq teste0(%rip), %rdx
leaq teste1(%rip), %rcx
leaq teste2(%rip), %r8
leaq teste3(%rip), %r9
movq $teste4, -8(%rbp)
movq $teste5, -16(%rbp)
movq $teste6, -24(%rbp)
movq teste7inteiro, %rbx
movq %rbx, -32(%rbp)
movq $teste8char, -40(%rbp)
movq $teste9char, -48(%rbp)
movq $teste10char, -56(%rbp)
movq $teste11char, -64(%rbp)
movq teste8inteiro, %rbx
movq %rbx, -72(%rbp)

# segundo teste (ordem dos parametros = %c%s%ld%c%s%c%s%s%s%s%s%ld%c)
# leaq teste8char(%rip),%rdx
# leaq teste0(%rip), %rcx
# movq teste7inteiro, %r8
# leaq teste9char(%rip), %r9
# movq $teste1, -8(%rbp)
# movq $teste10char, -16(%rbp)
# movq $teste2, -24(%rbp)
# movq $teste3, -32(%rbp)
# movq $teste4, -40(%rbp)
# movq $teste5, -48(%rbp)
# movq $teste6, -56(%rbp)
# movq teste8inteiro, %rbx
# movq %rbx, -64(%rbp)
# movq $teste11char, -72(%rbp)

# empilhar ao contrario os parametros da pilha
pushq -72(%rbp)
pushq -64(%rbp)
pushq -56(%rbp)
pushq -48(%rbp)
pushq -40(%rbp)
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
popq -40(%rbp)
popq -48(%rbp)
popq -56(%rbp)
popq -64(%rbp)
pushq -72(%rbp)

addq $72, %rsp
popq %rbp

# call fclose_SB

movq $SYS_exit, %rax
syscall
