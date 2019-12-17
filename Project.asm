	.data
fin:			.asciiz	"dictionary1"	#filename for input
buffer:			.space	2048
testWord:		.space	30
guessedString:		.space 50
charInputPrompt:	.asciiz "Enter a character.."
charInput:		.space 5
charInputHistory:	.space 30
matchPositions:		.space 20	#used to mark all the positions where there is a match
					#sets 1 to those positions, else remains 0
errorPrompt:		.asciiz	"the current error count is.."
hangPrompt:		.asciiz	"YOU WERE HANGED"
successPrompt:		.asciiz	"YOU WERE SAVED"
welcomeMsg:		.asciiz "|********************* WELCOME TO HANGMAN GAME ***********************|\n|***** You have to guess a correct word to escape death penalty *****|\n|HINT : it will always be one of the city of Islamic Republic of Pakistan|\n|*********************************************************************************|"
correctMsg:		.asciiz "Correct string was:  "

	.text
############################### THIS IS MAIN FUNCTION ########################################
main:

	li $v0, 55
	la $a0, welcomeMsg
	li $a1, 1
	syscall
	
	
	
##############################################################################################
################################ file work starts ############################################
##############################################################################################
	#opening the file
	li	$v0, 13
	la	$a0, fin
	li	$a1, 0
	li	$a2, 0
	syscall
	#########################################
	
	move	$s6, $v0	#save the file descriptor

	#now read the file just opened and store all of its content into buffer

	li	$v0, 14
	move	$a0, $s6
	la	$a1, buffer
	li	$a2, 1024
	syscall
	###################################

	move $s7, $v0		# now ********$s7 contains total number of characters in the buffer
	addi $s7, $s7, -10	#this will be used in random number generator (subreacting by amount equal to length of last word)

	#closing the file
	li	$v0, 16
	move	$a0, $s6
	syscall

################################# file work ends# ############################################
##############################################################################################



	jal randomGenerator
################## DEBUGGING PURPOSE #######################
#printing the buffer in dialogue box
#lw	$t0, buffer
#la	$a0, buffer
#li	$a1, 1
#li	$v0, 55
#syscall
############################################################


la $t0, buffer
add $t0, $t0, $a0		#add generated random number, currently $a0 contains the random number between 0 to 44
 
recur:  
	lb $t2, 0($t0)		#Load the first byte from address in $t2
	beq $t2, 0x2a, pointS	#if it encounters a * while reading characters, jump to storeWord function
	addi $t0, $t0, 1	#else increment the address unless it encounters a *
	j recur
	
	
    
	###################################
 	pointS:
	jal storeWord		#storeWord function is used for storing a random selecter word from buffer into testWord
############################################################

	## DEBUGGUING PURPOSE ##
	#li $v0, 55
	#li $a1, 1
	#la $a0, buffer
	#syscall
	
	#li $v0, 55
	#li $a1, 1
	#la $a0, testWord
	#syscall
	
	########################
	
	##calling strlen function
	la $a3, testWord	#$a3 is passed argument in strlen function
	jal strlen	#it returned testWord string length in $v0

	
	#loop for initializing guessedString with '_'s
	la $t0, guessedString
	li $t1, 0
	li $t2, 0x5f
	li $t3, 0x20
	move $t4, $v0	#saving the returned length of string into $t4
	
	whileA:
		beq $t1, $t4, exitA	#$t1 is counter that increments by 1 everytime loop runs
		sb $t2, 0($t0)		#store '_ ' in gussedString
		addi $t0, $t0, 1	#increment address pointer by 1
		sb $t3, 0($t0)		#store a space in gussedString
		addi $t0, $t0, 1	#increment address pointer by 1
		addi $t1, $t1, 1	#increment the counter used for iterating the loop
		j whileA
		
		exitA:
		li $t1, 0x0
		sb $t1, 0($t0)