# Read-only data section

.file	"assembly.s"      						# indicates the source file being assembled
.text                     						# switch to the text section where code is stored
.section	.rodata        						# start a new section for read-only data
.align 8                  						# align the following data on an 8-byte boundary
.LC0:                     						# define a label for this string
	.string	"Guess a number between 1 and 5: "  # string to prompt user for input
.LC1:                     						# define a label for this string
	.string	"%d"                           		# format specifier for integer input
.LC2:                     						# define a label for this string
	.string	"You win!"                     		# string to print if user guesses correctly
.LC3:                     						# define a label for this string
	.string	"You lose!"                    		# string to print if user guesses incorrectly
.text                     						# switch back to the text section

# Start of main function
# Prologue

.globl	main              						# make the main function visible to the linker
.type	main, @function    						# declare main as a function
main:                     						# main function label
.LFB6:                    						# label for start of function
	pushq	%rbp             					# push rbp onto stack
	movq	%rsp, %rbp       					# move the stack pointer to rbp
	subq	$32, %rsp        					# allocate 32 bytes of space on the stack for local variables
	movq	%fs:40, %rax     					# read the address of the current thread's stack guard
	movq	%rax, -8(%rbp)   					# store the stack guard value on the stack
	xorl	%eax, %eax       					# set eax to zero
	
#Initialize variables
	movl	$0, -28(%rbp)    					# initialize a variable to store the number of guesses
	movl	$5, -24(%rbp)    					# initialize a variable to store the maximum value for the guess
	movl	$1, -20(%rbp)    					# initialize a variable to store the minimum value for the guess
	movl	-24(%rbp), %eax  					# load the maximum value into eax
	subl	-20(%rbp), %eax  					# subtract the minimum value from eax
	addl	$1, %eax         					# add 1 to get the range of possible values
	movl	%eax, -16(%rbp)  					# store the range of possible values

#Generate a random number
	movl	$0, %edi        					# set the first argument to zero for the time function call
	call	time@PLT         					# call the time function to get the current time in seconds
	movl	%eax, %edi       					# store the time value in edi for the srand function call
	call	srand@PLT        					# seed the random number generator with the current time
	call	rand@PLT         					# generate a random number
	cltd                   						# sign-extend edx into eax for the idiv instruction
	idivl	-16(%rbp)        					# divide the random number by the range of possible values
	movl	-20(%rbp), %eax  					# load the minimum value into eax
	addl %edx, %eax       						# Add the quotient of the division to %eax

#Prompt for user guess
movl %eax, -12(%rbp)  							# Move the result to the memory location at -12(%rbp)
leaq .LC0(%rip), %rax 							# Load the address of the string .LC0 into %rax
movq %rax, %rdi       							# Move the value in %rax to %rdi (for use in printf)
movl $0, %eax         							# Move the value 0 to %eax (for use in printf)
call printf@PLT      							# Call the printf function to print the string in %rdi

#Scan user input
leaq -32(%rbp), %rax  							# Load the address of the memory location at -32(%rbp) into %rax
movq %rax, %rsi       							# Move the value in %rax to %rsi (for use in scanf)
leaq .LC1(%rip), %rax 							# Load the address of the string .LC1 into %rax
movq %rax, %rdi       							# Move the value in %rax to %rdi (for use in scanf)
movl $0, %eax         							# Move the value 0 to %eax (for use in scanf)
call __isoc99_scanf@PLT 						# Call the scanf function to read an integer into the memory location at -32(%rbp)
movl -32(%rbp), %eax  							# Move the value at -32(%rbp) to %eax

#Compare guess
cmpl %eax, -12(%rbp)  							# Compare the value at -12(%rbp) with the value at -32(%rbp)
jne .L2               							# If the values are not equal, jump to .L2

#User wins
leaq .LC2(%rip), %rax 							# Load the address of the string .LC2 into %rax
movq %rax, %rdi       							# Move the value in %rax to %rdi (for use in printf)
movl $0, %eax         							# Move the value 0 to %eax (for use in printf)
call printf@PLT      							# Call the printf function to print the string in %rdi
jmp .L3               							# Jump to .L3

#User loses
.L2:
	leaq	.LC3(%rip), %rax   					# load address of the format string for printf into %rax
	movq	%rax, %rdi        				 	# move the format string address to the first argument register %rdi
	movl	$0, %eax           					# move 0 into %eax register for the second argument (no arguments needed for the format string)
	call	printf@PLT       					# call printf function with the format string
	jmp	.L3                						# jump to label .L3

# Epilogue
.L3:
	movl	$0, %eax           					# move 0 to %eax register (return value)
	movq	-8(%rbp), %rdx     					# move the old base pointer value to %rdx
	je	.L5                 					# jump to label .L5
.L5:
	leave                    					# deallocate the stack frame
	ret                     					# return from the function


# Run with this command in ubuntu
# gcc -o program assembly.s && ./program
