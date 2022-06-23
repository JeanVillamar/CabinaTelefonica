.data
	inputP:	.asciiz "Cabina Telefónica"	#CABECERA
	espacio:	.asciiz " "
	saltoLinea:	.asciiz "\n"
	txt1InputMoney:	.asciiz "Ingrese modedas: "
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


#main
#main:	#jal printProducts
#	jal cobro
#	li $v0, 4		# salto de linea al final de cada loop
#	la $a0, saltoLinea
#	syscall
	
#	j main
#end:
#	li $v0, 4		# imprime mensaje de stock agotado
#	la $a0, txtEnd
#	syscall
#	li $v0, 10		# termina ejecucion del programa
#	syscall
	
#main

main:	jal cobrar
	li $v0, 4		# salto de linea al final de cada loop
	la $a0, saltoLinea
	syscall
	

end:	
	li $v0, 4		# imprime mensaje de stock agotado
	la $a0, finaltxt
	syscall
	li $v0, 10		# termina ejecucion del programa
	syscall


cobrar:	
	addi $sp, $sp, -4	#reservando memoria
	sw $ra, 0($sp)
	
	li $v0, 4
	la $a0, saltoLinea
	syscall
	
	la $a0, txt1InputMoney	#texto para input dinero
	syscall
	
	li $v0, 6		#input dinero $f0 contiene la respuesta
	syscall			# $f0=pay
	
	beq $v0,404,exception # si $v0 = 404 entonces hubo un error en el input ir a exception para continuar
	li $v0, 4
	la $a0, saltoLinea
	syscall
	
liberar_retornar:       
	lw $ra, 0($sp)		#liberando memoria y retornando
	addi $sp, $sp, 4
	jr $ra
	
exception:				#imprime mensaje en caso de ocurrir una excepción en alguno de los inputs y continua el programa
	la $a0, error1  	#imprimir error1
	li $v0, 4		
	syscall
	j liberar_retornar
