.equ STDIN, 0 			# standard input
.equ STDOUT, 1 			# standard output

.equ SYS_read, 0 		# read
.equ SYS_write, 1 		# write
.equ SYS_open, 2 		# file open
.equ SYS_close, 3 		# file close
.equ SYS_creat, 85 		# file open/create

.equ O_RDONLY, 0		# read only
.equ O_WDONLY, 1		# write only

.equ O_CREAT, 0100		

.equ S_MODE,  0700

.equ SYS_exit, 60 		# terminate

.equ STRLEN_LINE, 1
.equ STRLEN_OUPUT, 17

.equ SPACE, 32
.equ NEWLINE, 10
.equ END_OF_STRING, 0
.equ PERCENT, 37
.equ LETTER_s, 115
.equ LETTER_l, 108
.equ LETTER_d, 100
.equ LETTER_c, 99

.equ NEGATIVO, 45

.section .data
	# enterMsgString: .string "Enter a String: "
	parametrofopen: .string "w" # parametros implementados = w(somente escrita), r(somente leitura)
	parametrosfprintf: .string "FUNCIONA:%sSera?%sMesmo?%s %s funciona %s sim %s HA%s H A %ld H A A %c HA A A A %c \naÇaí %c é mUITO %c BOM \n%ld\n KKK"
	output_file: .string "output.txt" # arquivo de saida 
	
	
	fscanf_parametrosfopen: .string "r"
	parametrosfscanf: .string "%ld%s%s"
	input_file: .string "input.txt" # arquivo de entrada(# obs: arquivo de entrada deve conter \n no final)
	
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
	
	fscanf_buffer: .string "0"
	fscanf_str1: .string "12345678901234567890"
	fscanf_str2: .string "12345678901234567890"
	fscanf_str3: .string "12345678901234567890"
	fscanf_str4: .string "12345678901234567890"
	fscanf_qnt: .quad 0
	fscanf_char1: .byte '*'
	fscanf_char2: .byte '*'
	fscanf_char3: .byte '*'
	fscanf_char4: .byte '*'
	fscanf_char5: .byte '*'

.section .text
.globl _start

fopen_SB:
pushq %rbp
movq %rsp, %rbp

	parametro_r:
	movq $0, %r13
	movb (%rdi, %r13,1), %al

	cmpb $114, %al # parametro = r(114)
	jne parametro_w

		movq 	$SYS_open, %rax 	# file open/create
		leaq 	input_file(%rip), %rdi
		movq 	$O_RDONLY, %rsi
		# orq 	$O_WDONLY, %rsi		# write
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

fclose_SB:
pushq %rbp
movq %rsp, %rbp

	movq $SYS_close, %rax
	movq %rdi, %rdi
	syscall

popq %rbp
ret

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
			cmpb $LETTER_s, %bl
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
			cmpb $LETTER_l, %bl
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
			
			movq %r12, %rdi
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
			cmpb $LETTER_c, %bl
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

# "Voce possui: 50 reais !"
# fscaf(FILE * ptr, "%s%s%ld%s%s", str1, str2, &qnt, str3, str4);

# rsi = %s%s%d%s
# rdi = FILE * ptr
# rdx = str1 |poadspdoas\0|
# rcx = str2
# r8 = &qnt
# r9 = str3
# STACK <- str4

# ################################

fscanf:
	pushq %rbp
	movq %rsp, %rbp

	# %rax guarda posição atual da string
	movq $0, %rax

	# número de porcentagens na string
	movq $0, %r11

	# enquanto não for fim do vetor
	fscanf_condicao_1:
		movb (%rsi, %rax, 1), %bl
		cmpb $END_OF_STRING, %bl # Checa se terminou a string
		je fscanf_fim_while_1

		# verifica posicaoatual se é porcentagem
		# se for porcentagem
		cmpb $PERCENT, %bl
		jne fscanf_fim_if_1
			# incrementa posicão atual
			incq %rax

			# verifica qual o caractere após a porcentagem
			movb (%rsi, %rax, 1), %bl

			# Sobrescreve %r12 com o endereço da variável cujo índice é o índice da porcentagem atual
			fscanf_reg_1:
				cmpq $0, %r11
				jne fscanf_reg_2
				movq %rdx, %r12
				jmp fscanf_fim_regs

			fscanf_reg_2:
				cmpq $1, %r11
				jne fscanf_reg_3
				movq %rcx, %r12
				jmp fscanf_fim_regs

			fscanf_reg_3:
				cmpq $2, %r11
				jne fscanf_reg_4
				movq %r8, %r12
				jmp fscanf_fim_regs

			fscanf_reg_4:
				cmpq $3, %r11
				jne fscanf_pilha
				movq %r9, %r12
				jmp fscanf_fim_regs

			fscanf_pilha:
				subq $2, %r11
				movq (%rbp, %r11, 8), %r12
				addq $2, %r11

			fscanf_fim_regs:

	# %s /////////////////////////////////////////////////////////////////////////////// 
			fscanf_rotulo_s:
			# salta para rotulo especifico para tratar esse caractere %s
			cmpb $LETTER_s, %bl
			jne fscanf_rotulo_ld

			pushq %rax
			pushq %rdi
			pushq %rsi
			pushq %rdx
			pushq %rcx
			pushq %r8
			pushq %r9
			pushq %r11
			pushq %r12

			movq $0, %r11

			fscanf_while2:
				movq $SYS_read, %rax			# system code for read()
				# movq $STDOUT, %rdi			# standard output [%rdi já possui o endereço do arquivo]
				leaq fscanf_buffer(%rip), %rsi	# string address
				movq $1, %rdx					# length size

				pushq %rsi
				pushq %r11
				pushq %r12

				syscall

				popq %r12
				popq %r11
				popq %rsi

				# Move caractere lido em syscall para %r12[%r11].
				movq $0, %r13
				movb (%rsi, %r13, 1), %bl
				movb %bl, (%r12, %r11, 1)

				cmpb $NEWLINE, %bl # Checa se o caractere é newline.
				je verificar_se_no_inicio # Se for, verifica se está no início da string (ainda não leu caracteres válidos).
				cmpb $SPACE, %bl
				jne fscanf_incrementa_indice_string

				verificar_se_no_inicio:
				# Se o caractere for newline e estivermos no início da string, descarta o caractere.
				cmpq $0, %r11
				je fscanf_while2

				jmp fscanf_fim_while_2
				
				fscanf_incrementa_indice_string:
				incq %r11

				jmp fscanf_while2

			fscanf_fim_while_2:
			movq $0, (%r12, %r11, 1)

			popq %r12
			popq %r11
			popq %r9
			popq %r8
			popq %rcx
			popq %rdx
			popq %rsi
			popq %rdi
			popq %rax

			jmp fscanf_rotulo_fim_switch

	# %ld /////////////////////////////////////////////////////////////////////////////// 
			fscanf_rotulo_ld:
			cmpb $LETTER_l, %bl
			jne fscanf_rotulo_c
			incq %rax # vai para o 'd' do 'ld' (possivelmente há tratamento de erro para %l)
			
			pushq %rax
			pushq %rdi
			pushq %rsi
			pushq %rdx
			pushq %rcx
			pushq %r8
			pushq %r9
			pushq %r11
			pushq %r12

			movq $0, %r11  # Índice do algarismo lido até o momento

			movq $0, %rax  # Valor inteiro convertido
			movq $10, %rbx # Para multiplicar rax por 10.
			movq $0, %r13  # Flag: se for positivo terá 0, negativo terá 2

			fscanf_while3:
				
				pushq %r11
				pushq %r12
				pushq %r13
				pushq %rbx
				pushq %rax
				pushq %rdi

				movq $SYS_read, %rax			# system code for read()
				# movq $STDOUT, %rdi			# standard output [%rdi já possui o endereço do arquivo]
				leaq fscanf_buffer(%rip), %rsi	# string address
				movq $1, %rdx					# length size
				
				pushq %rsi

				syscall

				popq %rsi
				popq %rdi
				popq %rax
				popq %rbx
				popq %r13
				popq %r12
				popq %r11
			
				# Move caractere lido em syscall para %r10b.
				movq $0, %r15
				movb (%rsi, %r15, 1), %r10b

				cmpb $NEWLINE, %r10b # Checa se o caractere é newline.
				je ld_verificar_se_no_inicio # Se for, verifica se está no início do inteiro (ainda não leu caracteres válidos).
				cmpb $SPACE, %r10b
				jne fscanf_incrementa_indice_algarismo

				ld_verificar_se_no_inicio:
				# Se o caractere for newline e estivermos no início do inteiro, descarta o caractere.
				cmpq $0, %r11
				je fscanf_while3

				jmp fscanf_fim_while_3
				
				fscanf_incrementa_indice_algarismo:
				incq %r11

				# Verifica se é negativo
				cmpb $NEGATIVO, %r10b
				jne proximo_digito_string_inteiro
				movq $2, %r13

				jmp fscanf_while3

				proximo_digito_string_inteiro:
				pushq %rdx

				movq $0, %rdx
				movzbq %r10b, %r14
				subq $48, %r14

				# %rax = %rax * 10 + %r14
				mulq %rbx 
				addq %r14, %rax

				popq %rdx

				jmp fscanf_while3

			fscanf_fim_while_3:
				cmpq $2, %r13
				jne nao_negativo
				negq %rax

			nao_negativo:
			movq %rax, (%r12) 
			movq %rax, %r10 	# teste para fscanf

			popq %r12
			popq %r11
			popq %r9
			popq %r8
			popq %rcx
			popq %rdx
			popq %rsi
			popq %rdi
			popq %rax

			jmp fscanf_rotulo_fim_switch
	# %c /////////////////////////////////////////////////////////////////////////////// 
			fscanf_rotulo_c:
			cmpb $LETTER_c, %bl
			jne fscanf_rotulo_fim_switch

			pushq %rax
			pushq %rdi
			pushq %rsi
			pushq %rdx
			pushq %rcx
			pushq %r8
			pushq %r9
			pushq %r11

			# rdi = FILE * ptr
			# mov fscanf_str1 -> %rsi
			# mov 5
			# r12 = str1
			
			movq $SYS_read, %rax		# system code for read()
			# movq $STDOUT, %rdi		# standard output [%rdi já possui o endereço do arquivo]
			movq %r12, %rsi				# string adress
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

			jmp fscanf_rotulo_fim_switch
		
	# fim escolhas para % ///////////////////////////////////////////////////
			fscanf_rotulo_fim_switch:
			# incrementa numero de porcentagens
			incq %r11
			# incrementa posicao atual
			incq %rax
			jmp fscanf_condicao_1
		fscanf_fim_if_1:

		# incrementa posicao atual
		incq %rax

		jmp fscanf_condicao_1
	fscanf_fim_while_1:
	
	movq %r10, %rax # teste para fscanf
	
popq %rbp
ret

_start:
pushq %rbp
movq %rsp, %rbp

# movq $parametrofopen, %rdi
# call fopen_SB
# movq %rax, %rdi # move o ponteiro do arquivo para rdi

# leaq parametrosfprintf(%rip), %rsi

# subq $72, %rsp
# ############## TESTE fprintf 1
# variaveis(necessario estar em ordem com os parametros):
# (ordem dos parametros(rsi) = "FUNCIONA:%sSera?%sMesmo?%s %s funciona %s sim %s HA%s H A %ld H A A %c HA A A A %c \naÇaí %c é mUITO %c BOM \n%ld\n KKK)

# leaq teste0(%rip), %rdx
# leaq teste1(%rip), %rcx
# leaq teste2(%rip), %r8
# leaq teste3(%rip), %r9
# movq $teste4, -8(%rbp)
# movq $teste5, -16(%rbp)
# movq $teste6, -24(%rbp)
# movq teste7inteiro, %rbx
# movq %rbx, -32(%rbp)
# movq $teste8char, -40(%rbp)
# movq $teste9char, -48(%rbp)
# movq $teste10char, -56(%rbp)
# movq $teste11char, -64(%rbp)
# movq teste8inteiro, %rbx
# movq %rbx, -72(%rbp)

# ############## TESTE fprintf 2
# variaveis(necessario estar em ordem com os parametros):
# (ordem dos parametros(rsi) = %c%s%ld%c%s%c%s%s%s%s%s%ld%c)

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

# passando as variaveis como parametro por pilha:
# empilhar ao contrario os parametros da pilha
# pushq -72(%rbp)
# pushq -64(%rbp)
# pushq -56(%rbp)
# pushq -48(%rbp)
# pushq -40(%rbp)
# pushq -32(%rbp)
# pushq -24(%rbp)
# pushq -16(%rbp)
# pushq -8(%rbp)

# call fprintf
# movq %rax, %rdi

# addq $72, %rsp

# ############## TESTE fscanf
# Crie um arquivo chamado input.txt
# Coloque o texto que quiser
# Termine ele com '\n'.
# Altere a variavel global 
# Para refletir o texto inserido em input.txt
# Exemplo para o texto "123 ola mundo\n"
# parametrosfscanf: .string "%ld%s%s"
# comente o codigo do fprintf e tire os comentarios do codigo aba

movq $fscanf_parametrosfopen, %rdi
call fopen_SB
movq %rax, %rdi

leaq parametrosfscanf(%rip), %rsi
leaq fscanf_qnt(%rip), %rdx
leaq fscanf_str1(%rip), %rcx
leaq fscanf_str2(%rip), %r8

leaq fscanf_qnt(%rip), %rdx
call fscanf
movq %rax, %rdi

call fclose_SB

popq %rbp

movq $SYS_exit, %rax
syscall
