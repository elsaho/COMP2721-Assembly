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
# prologue

.globl	main              						# make the main function visible to the linker
.type	main, @function    						# declare main as a function
main:                     						# main function label
.LFB6:                    						# label for start of function
	.cfi_startproc         						# specify start of procedure in the debug info
	endbr64                						# enable end branch speculation on indirect jumps
	pushq	%rbp             					# push rbp onto stack
	.cfi_def_cfa_offset 16 						# establish stack frame
	.cfi_offset 6, -16     						# save rbp to previous location on stack
	movq	%rsp, %rbp       					# move the stack pointer to rbp

# function 
	.cfi_def_cfa_register 6 					# update the current frame address register
	subq	$32, %rsp        					# allocate 32 bytes of space on the stack for local variables
	movq	%fs:40, %rax     					# read the address of the current thread's stack guard
	movq	%rax, -8(%rbp)   					# store the stack guard value on the stack
	xorl	%eax, %eax       					# set eax to zero
	movl	$0, -28(%rbp)    					# initialize a variable to store the number of guesses
	movl	$5, -24(%rbp)    					# initialize a variable to store the maximum value for the guess
	movl	$1, -20(%rbp)    					# initialize a variable to store the minimum value for the guess
	movl	-24(%rbp), %eax  					# load the maximum value into eax
	subl	-20(%rbp), %eax  					# subtract the minimum value from eax
	addl	$1, %eax         					# add 1 to get the range of possible values
	movl	%eax, -16(%rbp)  					# store the range of possible values
	movl	$0, %edi        					# set the first argument to zero for the time function call
	call	time@PLT         					# call the time function to get the current time in seconds
	movl	%eax, %edi       					# store the time value in edi for the srand function call
	call	srand@PLT        					# seed the random number generator with the current time
	call	rand@PLT         					# generate a random number
	cltd                   						# sign-extend edx into eax for the idiv instruction
	idivl	-16(%rbp)        					# divide the random number by the range of possible values
	movl	-20(%rbp), %eax  					# load the minimum value into eax
	addl %edx, %eax       						# Add the quotient of the division to %eax
movl %eax, -12(%rbp)  							# Move the result to the memory location at -12(%rbp)
leaq .LC0(%rip), %rax 							# Load the address of the string .LC0 into %rax
movq %rax, %rdi       							# Move the value in %rax to %rdi (for use in printf)
movl $0, %eax         							# Move the value 0 to %eax (for use in printf)
call printf@PLT      							# Call the printf function to print the string in %rdi
leaq -32(%rbp), %rax  							# Load the address of the memory location at -32(%rbp) into %rax
movq %rax, %rsi       							# Move the value in %rax to %rsi (for use in scanf)
leaq .LC1(%rip), %rax 							# Load the address of the string .LC1 into %rax
movq %rax, %rdi       							# Move the value in %rax to %rdi (for use in scanf)
movl $0, %eax         							# Move the value 0 to %eax (for use in scanf)
call __isoc99_scanf@PLT 						# Call the scanf function to read an integer into the memory location at -32(%rbp)
movl -32(%rbp), %eax  							# Move the value at -32(%rbp) to %eax
cmpl %eax, -12(%rbp)  							# Compare the value at -12(%rbp) with the value at -32(%rbp)
jne .L2               							# If the values are not equal, jump to .L2
leaq .LC2(%rip), %rax 							# Load the address of the string .LC2 into %rax
movq %rax, %rdi       							# Move the value in %rax to %rdi (for use in printf)
movl $0, %eax         							# Move the value 0 to %eax (for use in printf)
call printf@PLT      							# Call the printf function to print the string in %rdi
jmp .L3               							# Jump to .L3
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
	subq	%fs:40, %rdx       					# subtract the value of %fs:40 from %rdx to check if the stack has been corrupted
	je	.L5                 					# jump to label .L5 if the stack is not corrupted
	call	__stack_chk_fail@PLT 				# call __stack_chk_fail if the stack has been corrupted
.L5:
	leave                    					# deallocate the stack frame
	.cfi_def_cfa 7, 8
	ret                     					# return from the function
	.cfi_endproc

# Metadata and debugging information
# This part is not necessary to make the program run

/*
.LFE6:
	.size	main, .-main      					# End of function 'main', set its size
	.ident	"GCC: (Ubuntu 11.3.0-1ubuntu1~22.04) 11.3.0" 		# Compiler version information
	.section	.note.GNU-stack,"",@progbits 					# Marks the stack as non-executable
	.section	.note.gnu.property,"a" 							# Marks the binary as containing GNU properties
	.align 8 													# Aligns the next instruction on an 8-byte boundary
	.long	1f - 0f 											# Length of .note.gnu.build-id section
	.long	4f - 1f 											# Length of .note.gnu.property section
	.long	5 													# Value of the note type
0:
	.string	"GNU" 												# Note section name
1:
	.align 8 													# Aligns the next instruction on an 8-byte boundary
	.long	0xc0000002 											# Property type (Tag_GNU_property_stack_size)
	.long	3f - 2f 											# Length of property value
2:
	.long	0x3 												# Property value (0x300, or 768 bytes)
3:
	.align 8 													# Aligns the next instruction on an 8-byte boundary
4: 																# End of the .note.gnu.property section
*/

# Run with this command in ubuntu
# gcc -o program assembly.s && ./program
