.data
	.eqv len 10
	texto:	.space len
	inputP:	.asciiz "Cabina Telef?nica"	#CABECERA
	espacio:	.asciiz " "
	saltoLinea:	.asciiz "\n"

	cadleida: .space 11
	cada: .byte 'a'

	txtSaldo:.asciiz "Saldo: $"
	denominaciones: .float 0.05, 0.10, 0.25, 0.50, 1.00	#lista de denimonaciones validas
	denominacionesLength: .word 5	#longitud de la  lista de denominaciones
	
	txtCosto:	.asciiz "Costo de llamada por minuto: $"

	
	
	
	error1:	.asciiz " - Moneda Incorrecta\n"
	error2: .asciiz " Ingrese un numero telefonico valido\n"
	error3:	.asciiz "El monto no es suficiente para realizar una llamada\n"
	
	
	txt1InputMoney:	.asciiz "Ingrese modedas: "
	txtnumllamada:.asciiz"Ingrese el numero a llamar:"
	txt3InputIniciar: .asciiz "Iniciar Llamada?"
	msg3:.asciiz "\n--Adios, no olvide su reembolso--"

	txtSi:		.asciiz"si"
	str1: .space 3
	str2: .space 3

	alarmtxt1:	.asciiz ".Llamada en curso - - - - Presiona C para colgar\n"
	txtC: 	.asciiz"C\n"
	str3: .space 4
	
	llamadatxt1:	.asciiz "Duracion de la llamada: 00:00:0"
	min: .float 60.0	
	
	
	costoT: .asciiz "Costo de la llamada: $"
	cambioTxt:	.asciiz "Su cambio es: "
	finaltxt: .asciiz "Gracias por Preferirnos"
	dividir: .float 100

	
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
	li $v0, 4		# salto de linea 
	la $a0, saltoLinea
	syscall
	
	jal llamadaCurso
	jal duracionllamada
	jal costoLlamadaT
	jal cambio

end:	
	li $v0, 4		# salto de linea 
	la $a0, saltoLinea
	syscall
	li $v0, 4		
	la $a0, finaltxt
	syscall
	li $v0, 10		# termina ejecucion del programa
	syscall


cambio:
	li $v0, 4		# salto de linea  
	la $a0, saltoLinea
	syscall

	li $v0, 4		
	la $a0, cambioTxt
	syscall

	sub.s $f12 ,$f11,$f12
	li $v0, 2	
	syscall
	
	jr $ra
	
	
duracionllamada:
	li $v0, 4		#duracion llamada
	la $a0, llamadatxt1
	syscall
	
	li $v0, 1	
	subi $t6 , $t6, 1
	add $a0, $zero, $t6	
	syscall			#imprimir contador segundo
	
	li $v0, 4		# salto de linea 
	la $a0, saltoLinea
	syscall

	jr $ra
	
	
costoLlamadaT:
	addi $sp, $sp, -4	#reservando memoria
	sw $ra, 0($sp)
	
	li $v0,4
	la $a0, costoT
	syscall
	
	lwc1 $f5, min  #f5 = 60.0
	
	#int a float
	mtc1 $t6, $f1		
	cvt.s.w $f1, $f1	#$f1= 6.0
	
	#add.s $f12,$f1,$f7
	
	div.s $f12,$f1,$f5	#$f12 = 6.0/60.0= 0.1
	
	mul.s $f12,$f0,$f12	#f12 = precioCostoMinuto *f12
	li $v0, 2	
	syscall

	
	
	lw $ra, 0($sp)		#liberando memoria y retornando
	addi $sp, $sp, 4
	jr $ra
	



llamadaCurso:
	addi $sp, $sp, -4	#reservando memoria
	sw $ra, 0($sp)
	li $v0, 4

	li $v0, 4		# salto de linea 
	la $a0, alarmtxt1
	syscall		 

	li $v0, 8
	la $a0,str3
	addi $a1,$zero,4
	syscall
	
	la $a0,str3  #pass address of str1
	la $a1,txtC  #pass address of str2
	jal strcmp2  #call strcmp
	
	beq $v0,$zero,ok2	 #check result
	li $v0,4
	la $a0,msg3
	syscall
	li $v0,10
	syscall
ok2:
	lw $ra, 0($sp)		#liberando memoria y retornando
	addi $sp, $sp, 4
	jr $ra
	
strcmp2:
	add $t0,$zero,$zero
	add $t1,$zero,$a0
	add $t2,$zero,$a1
	add $t3,$zero,$zero
	add $t4,$zero,$zero
	add $t5,$zero,$zero
	loop2:
		li $v0, 32		#sleep de 1 seg		
	        la $a0, 1000 
		syscall
		
		li $v0, 1	
		add $a0, $zero, $t6	
		syscall			#imprimir contador segundo
		
		li $v0, 4		
		la $a0, alarmtxt1
		syscall			#imprimir "llamada en curso"
		addi $t6,$t6,1 #contador de segundos $t6 +1
	
	
		lb $t3($t1)  #load a byte from each string
		lb $t4($t2)
		beqz $t3,checkt3 #str1 end
		beqz $t4,missmatch2
		slt $t5,$t3,$t4  #compare two bytes
		bnez $t5,missmatch2
		addi $t1,$t1,1  #t1 points to the next byte of str1
		addi $t2,$t2,1
		j loop2	
		
missmatch2: 
	addi $v0,$zero,1
	j endfunction2

checkt3:
	bnez $t4,missmatch
	add $v0,$zero,$zero

endfunction2:
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
	addi $a1,$zero,3
	syscall
	
	la $a0,str1  #pass address of str1
	la $a1,txtSi  #pass address of str2
	jal strcmp  #call strcmp
	
	beq $v0,$zero,ok	 #check result
	li $v0,4
	la $a0,msg3
	syscall
	li $v0,10
	syscall
ok:
	lw $ra, 0($sp)		#liberando memoria y retornando
	addi $sp, $sp, 4
	jr $ra
	
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
	jr $ra

	
	

	
	


printCosto:
	li $v0, 4		# salto de linea 
	la $a0, txtCosto
	syscall
		
	#generar float aleatorio
	li $v0, 42
	li $a1, 50
	syscall
	
	add $t0, $a0, $zero    
	mtc1 $t0, $f1
	cvt.s.w $f2, $f1
	add.s $f3, $f1, $f2
        
	lwc1 $f5, dividir
	div.s $f0,$f3,$f5     	
	
	add.s $f12, $f0, $f4
	li $v0, 2
	syscall
     	
	jr $ra
	
	
	

numLlamada:
	li $v0, 4
	la $a0,txtnumllamada
	syscall

	li $v0, 8  #Llamada al sistema para leer una cadeno
	la $a0, cadleida #Le indico que me la guarde en la posici?n de memoria cadleida
	li $a1,11  #Longitud m?xima de la cadena = 9
	syscall
	
	la $t0, cadleida #Inicializo un puntero a la cadena
	li $t1, 0  #Inicializo la longitud de la cadena
	lb $a2, cada #mover caractera a a2
	
	li $t3, 1 #contador para validacion del numero
 	
	bucle:
		lb $t2, ($t0)  #Leo un byte (car?cter) de la cadena
		
		beq $t2, $zero, fin #Compruebo si he llegado al final de la cadena ('\0'=0)
		beq $a2, $t2, etiq
		addi $t0, $t0, 1 #Actualizo el puntero para que apunte al siguiente car?cter
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
		add.s $f11,$f2,$f4
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

	
	
	
