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
			####################################################################################		
	#print initial blank guessed string
	li $v0, 55
	la $a0, guessedString
	li $a1, 1
	syscall

	
	li $s5, 0	#initializing error count
	# Loop used for asking a character from user, displaying current status of string, call Hangman Draw function
	mainLoop:
		#if (errorcount == MAX) --> exit mainLoop
		beq $s5, 9, exitMainLoop	#$t7 acts as error count 

		############ Counting the number of remaining '_' in guessedString ###################
		la $t0, guessedString
		li $t1, 0
		li $s4, 0x5f
		
		loopx:
		lb $t2, 0($t0)
		beqz $t2, exitLoopx
		addi $t0, $t0, 1
		bne $t2, $s4, loopx
		addi $t1, $t1, 1
		j loopx
		exitLoopx:

		beqz $t1, exitMainLoop
		########################################################################################
		jal promptChar
		move $t0, $v0	#$t0 contains the character read

		la $t4, matchPositions
		li $t5, 1
		#so let's just first calculate the length of testWord
		la $t1, testWord
		li $t3, 0	#used in set mark in 'matchPositions'
		#move $a3, $t1
		#jal strlen
		#move $t2, $v0	#now $t2 contains length of testWord
		
		#this loop will check if this char($t0) is part of correct answer/string
		li $t6, 0	
		shortLoop:
			lb $t2, 0($t1)		# Load the first byte from address in $t1(testWord)
			beqz $t2, endl		#done with checking this input character, now accept another character from user (i.e. go to mainLoop again)
			bne $t2, $t0, nextShortLoop
			sb $t5, 0($t4)			#if character match than set mark in 'matchPositions'
			
			############ call matchSound
			jal matchSound
			############################ 
			li $t6, 1			#used as flag to check
		
		nextShortLoop:
			addi $t1, $t1, 1	# else increment the address  
			#add $t3, $t3, 1
			add $t4, $t4, 1		#increment mark for matchpositions
			j shortLoop
		
			
		endl:			#it's done with checking this particular char and have set 'matchPositions' array also
			beqz $t6, errCount 		# if($t6==0)--> $t7++
			j noError
			errCount:
			addi $s5, $s5, 1	#error count is stored in $s5
			move $a0, $s5		#passing this error count argument in drawHAngman subroutine
			jal drawHangman
				beq $s5, 9, hangPrompt1
			
			
			noError:
			move $a0, $t0
			jal setChar	#now call setChar function for putting this character in 'guessedWord' at positions specified in matchPositions
	
		jal printGuessedString	
		j mainLoop
		
			hangPrompt1:
				li $v0, 55
				la $a0, hangPrompt
				li $a1, 0
				syscall
			###############################################
	li $v0, 59
	la $a0, correctMsg
	la $a1, testWord
	syscall
	###############################################

								
				
		exitMainLoop:
		blt $s5, 9, success
		j main_exit
		
		success:
		
			##play success sound
			li $v0, 33
			li $a0, 60	# pitch, C#
			li $a1, 2000	#duration in milisecond
			li $a2, 119	#instrument (0 - 7 piano)
			li $a3, 300	#volume
			syscall		
			
			##display success sound
			##display succcess message
			li $v0, 55
			la $a0,  successPrompt
			li $a1, 1
			syscall

			
	## DEBUGGUING PURPOSE ##
	#li $v0, 55
	#li $a1, 1
	#la $a0, guessedString
	#syscall
	
	#li $v0, 55
	#li $a1, 1
	#la $a0, testWord
	#syscall
	########################

	#jal drawHangman

	main_exit:
	li	$v0, 10
	syscall
######################################### MAIN ENDS ############################################


###### THIS FUNCTION GENERATES A RANDOM NUMBER AND RETURNS IT IN $a0 
randomGenerator:
	#$s7 contains the length of buffer - 10, Hence this function generates a random number used in selecting a state form buffer strinf
	move $a1, $s7	#Range set from 0-44 in this case (total characters in buffer are 55 so it will generate random # from 0 to 44)
	li $v0, 42	#generates random number and put it in $a0
	syscall
	jr $ra
#####################################################################


###### THIS FUNCTION IS FOR STORING A RANDOM SELECTED WORD FROM BUFFER INTO TESTWORD
storeWord:
	la $t1, testWord
	addi $t0, $t0, 1
	whileSW:
	lb $t2, 0($t0)
	beq $t2, 0x2a, exitStoreWord	#exit if reaches to the end of current word
	beqz $t2, exitStoreWord		#eit of reached end of buffer string
	sb $t2, 0($t1)
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j whileSW
	
	exitStoreWord:
	li $t3, 0x00
	sb $t3, 0($t1)
	jr $ra
####################################################################################
	

###### THIS FUNCTION CALCULATES THE STRING LENGTH OF TESTWORD AND RETURNS IT IN $v0
## Argument passed $a3, contains address of the string whose length is to calculate
## Return value $v0, length of string
strlen:
	li $v0, 0
	loopStrLen:
	lb $t2, 0($a3)  # Load the first byte from address in $t0  
	beqz $t2, endStrlen   # if $t2 == 0 then go to label end  
	addi $a3, $a3, 1      # else increment the address  
	addi $v0, $v0, 1 # and increment the counter of course  
	j loopStrLen      # finally loop  

	endStrlen:
	jr $ra  
###################################################################################


###### THIS FUNCTION USED TO TAKE INPUR FROM THE USER #############################
## return value, read character in $v0
promptChar:
	la $t3, charInputHistory	
	move $a3, $t3			#going to call strlen, so storing address of string in $a3(argument for strlen function)
	addi $sp, $sp, -4		#storing current $ra (i.e some line # of main), on stack
	sw $ra, 0($sp)			#because going to call strlen, that will overwrite $ra
	
	jal strlen			#this will return the length of charInputHistory string into $v0
	move $t0, $v0			#$t0 has length of charInputHistory
	
	promptCharLoop:			#if the char has already been input (present in history) then come here again
		li $v0, 54
		la $a0, charInputPrompt
		la $a1, charInput
		li $a2, 2
		syscall
		
		la $t1, charInput
		lb $t2, 0($t1)		#now $t2 has the user input character
		#there is nothing in charInputHistory array	
		beqz $t0, checkHistoryLoopExit
		
		#check whether $t2 has previously been inputed by running a loop on charInputHistory, $t0 times
		checkHistoryLoop:
			lb $t4, 0($t3)
			beqz $t4, checkHistoryLoopExit	#have reached end of 'charInputHistory' string
			beq $t4, $t2, promptCharLoop	#means user has previously inputed the same char and hence need to input again
			addi $t3, $t3, 1
			j checkHistoryLoop
			
			
	checkHistoryLoopExit:
#	addi $t3, $t3, 1	#store the new input in charInputHistory char array
	sb $t2, 0($t3)
	
	lw $ra, 0($sp)			#restoring $ra from stack to get back to somewhere in main
	addi $sp, $sp, 4
	move $v0, $t2			#returns the read char in $v0
	jr $ra
###################################################################################


###################################################################################