.data
	.eqv len 10
	texto:	.space len
	inputP:	.asciiz "Cabina Telefónica"	#CABECERA
	espacio:	.asciiz " "
	saltoLinea:	.asciiz "\n"

	cadleida: .space 11
	cada: .byte 'a'

	txtSaldo:.asciiz "Saldo: $"
	denominaciones: .float 0.05, 0.10, 0.25, 0.50, 1.00	#lista de denimonaciones validas
	denominacionesLength: .word 5	#longitud de la  lista de denominaciones
	
	txtCosto:	.asciiz "Costo de llamada: $"
	costoLlamada: .float 0.12	
	
	
	
	error1:	.asciiz " - Moneda Incorrecta\n"
	error2: .asciiz " Ingrese un número telefónico válido\n"
	error3:	.asciiz "El monto no es suficiente para realizar una llamada\n"
	
	
	txt1InputMoney:	.asciiz "Ingrese modedas: "
	txtnumllamada:.asciiz"Ingrese el número a llamar:"
	txt3InputIniciar: .asciiz "Iniciar Llamada?"
	txtSi:		.asciiz"si\n"
	str1: .space 3
	str2: .space 3


	alarmtxt1:	.asciiz "Llamada en curso - - - - Presiona C para colgar"
	llamadatxt1:	.asciiz "Duración de la llamada:"

	cambioTxt:	.asciiz "Su cambio es:"
	finaltxt: .asciiz "Gracias por Preferirnos"
	
	
	cadLong: .asciiz "El numero de aes es: "

.text
.globl main



main:	jal cobrar
	li $v0, 4		# salto de linea 
	la $a0, saltoLinea
	syscall
	jal numLlamada
	li $v0, 4		# salto de linea 
	la $a0, saltoLinea
	syscall
	jal printCosto
	jal confLlamada
	jal llamadaCurso

	

end:	
	li $v0, 4		# salto de linea 
	la $a0, saltoLinea
	syscall
	li $v0, 4		
	la $a0, finaltxt
	syscall
	li $v0, 10		# termina ejecucion del programa
	syscall


llamadaCurso:
	li $v0, 4		
	la $a0, alarmtxt1
	syscall
	jr $ra	

	

confLlamada:
	addi $sp, $sp, -4	#reservando memoria
	sw $ra, 0($sp)
	li $v0, 4

	li $v0, 4		# salto de linea 
	la $a0, saltoLinea
	syscall
	li $v0, 4		 
	la $a0, txt3InputIniciar
	syscall
	li $v0, 8
	la $a0,str1
	addi $a1,$zero,20
	syscall
	
	la $a0,str1  #pass address of str1
	la $a1,txtSi  #pass address of str2
	jal strcmp  #call strcmp
	
	beq $v0,$zero,endfunction #check result
	li $v0, 10		# termina ejecucion del programa
	syscall
	
strcmp:
	add $t0,$zero,$zero
	add $t1,$zero,$a0
	add $t2,$zero,$a1
	loop:
		lb $t3($t1)  #load a byte from each string
		lb $t4($t2)
		beqz $t3,checkt2 #str1 end
		beqz $t4,missmatch
		slt $t5,$t3,$t4  #compare two bytes
		bnez $t5,missmatch
		addi $t1,$t1,1  #t1 points to the next byte of str1
		addi $t2,$t2,1
		j loop

missmatch: 
	addi $v0,$zero,1
	j endfunction

checkt2:
	bnez $t4,missmatch
	add $v0,$zero,$zero

endfunction:
	lw $ra, 0($sp)		#liberando memoria y retornando
	addi $sp, $sp, 4
	jr $ra

	
	


printCosto:
	li $v0, 4		# salto de linea 
	la $a0, txtCosto
	syscall
	

	lwc1 $f0, costoLlamada	#obteniendo el valor de de "CostoLlamada"
	li $v0, 2
	add.s $f12,$f0,$f4

	la $a0, saltoLinea
	syscall
	jr $ra
	
	

numLlamada:
	li $v0, 4
	la $a0,txtnumllamada
	syscall

	li $v0, 8  #Llamada al sistema para leer una cadeno
	la $a0, cadleida #Le indico que me la guarde en la posición de memoria cadleida
	li $a1,11  #Longitud máxima de la cadena = 9
	syscall
	
	la $t0, cadleida #Inicializo un puntero a la cadena
	li $t1, 0  #Inicializo la longitud de la cadena
	lb $a2, cada #mover caractera a a2
	
	li $t3, 1 #contador para validacion del numero
 	
	bucle:
		lb $t2, ($t0)  #Leo un byte (carácter) de la cadena
		
		beq $t2, $zero, fin #Compruebo si he llegado al final de la cadena ('\0'=0)
		beq $a2, $t2, etiq
		addi $t0, $t0, 1 #Actualizo el puntero para que apunte al siguiente carácter
		addi $t3, $t3, 1 #Actualizo el contador
		j bucle   #Continuo recorriendo la cadena
 
		etiq:   
		
			addi $t1, $t1, 1 #Actualizo el contador
			addi $t0, $t0, 1 #Actualizo el puntero para que apunte al siguiente car?ter
			j bucle   #Continuo recorriendo la cadena

		fin: 
			
			bne $t3,$a1,errortwo
			jr $ra				
			
			errortwo:	
				li $v0, 4
				la $a0, error2
				syscall
				j numLlamada


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
					li $v0, 4
					la $a0, error1
					syscall
					li $t3, 0
					jr $ra

	
	
