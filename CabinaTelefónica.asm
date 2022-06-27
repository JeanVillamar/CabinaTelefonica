.data
	.eqv len 10
	texto:	.space len
	inputP:	.asciiz "Cabina Telefónica"	#CABECERA
	espacio:	.asciiz " "
	saltoLinea:	.asciiz "\n"
	txt1InputMoney:	.asciiz "Ingrese modedas: "
	txtnumllamada:.asciiz"Ingrese el número a llamar:"
	txtSaldo:.asciiz "Saldo: $"
	denominaciones: .float 0.05, 0.10, 0.25, 0.50, 1.00	#lista de denimonaciones validas
	denominacionesLength: .word 5	#longitud de la  lista de denominaciones
	
	error1:	.asciiz " - Moneda Incorrecta\n"
	error2: .asciiz " Ingrese un número telefónico válido\n"
	error3:	.asciiz "El monto no es suficiente para realizar una llamada\n"
	txt2InputNumero:	.asciiz "Ingrese el número telefónio"
	txt3InputIniciar: .asciiz "Iniciar Llamada"	
	alarmtxt1:	.asciiz "Llamada en curso - - - - Presiona C para colgar"
	llamadatxt1:	.asciiz "Duración de la llamada:"
	costotxt: .asciiz "Costo de la llamada"
	cambioTxt:	.asciiz "Su cambio es:"
	finaltxt: .asciiz "Gracias por Preferirnos"
.text
.globl main



main:	jal cobrar
	li $v0, 4		# salto de linea 
	la $a0, saltoLinea
	
	jal numLlamada
	
	

end:	
	li $a0, 0
	li $v0, 4		# salto de linea 
	la $a0, saltoLinea
	li $v0, 4		
	la $a0, finaltxt
	syscall
	li $v0, 10		# termina ejecucion del programa
	syscall

numLlamada:
	li $v0, 4
	la $a0,txtnumllamad
	
	jr $ra
	

cobrar:	
	addi $sp, $sp, -4	#reservando memoria
	sw $ra, 0($sp)
	li $v0, 4
	la $a0, saltoLinea
	syscall
	
	li $t3, 1

	
	buclecobr:
		li $v0, 4
		la $a0, txt1InputMoney	#texto para input dinero
		syscall
		li $v0, 6
		syscall			# $f0=pay
		jal validarDenominacion
		bne $t3, $zero, buclecobr		
	
	cobroExitoso:
		li $v0, 4
		la $a0, txtSaldo
		syscall
		li $v0,2
		add.s $f12,$f2,$f4
		la $a0, saltoLinea	
		syscall
		li $a0, 0
		li $v0, 4
		la $a0, saltoLinea	
		syscall
		
		jal liberar_retornar
	
liberar_retornar:       
	lw $ra, 0($sp)		#liberando memoria y retornando
	addi $sp, $sp, 4
	jr $ra

	
validarDenominacion:
	li $t0, 0
	lw $t5, denominacionesLength
	sll $t5, $t5, 2				#lenght*4  -> "5*4"
	
	whilef4:
		beq $t0, $t5, exitf4		# if index == (length * 4) ir a exitf4 -> if(index==20) then exitf4
		lwc1 $f1, denominaciones($t0)	#obteniendo el valor de denominaciones[index]
		addi $t0, $t0, 4		#aumentando index
		
		c.eq.s $f0, $f1		#input==denominaciones[index]
		bc1f whilef4		#if false regresar a while
		
		add.s $f2, $f2, $f1	#Acumulador
		li $v0, 1		#si es valida v0=1
		li $t3, 1
		jr $ra
		
	exitf4:
		#li $v0, 0	 		#si no es valida v0=0
		li $v0, 4
		la $a0, error1
		syscall
		li $t3, 0
		jr $ra

	
	
