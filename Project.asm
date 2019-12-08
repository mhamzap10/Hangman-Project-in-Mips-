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