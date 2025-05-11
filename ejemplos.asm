
###############################################################
### 			BITMAP SETTINGS			    ###	
###							    ###
###	Unit Width in pixels: 8 			    ###
###	Unit Heigh in Pixels: 8				    ###
###	Display Width in Pixels: 512			    ###
###	Display Height in Pixels: 256  			    ###
###	Base address for display 0x10010000 (static data)   ###
###							    ###	
###############################################################

.data

frameBuffer: 	.space 	0x80000		#512 wide x 256 high pixels, JUST THE SIZE OF THE MEMORY FOR THE SCREEN, NOT THE ADRESS WICH IS 0x1001000. ###	Base address for display 0x10010000 (static data)   ###

#AFTER THIS WE HAVE:

#Each .word directive allocates 4 bytes in the .data section.
##The assembler places these variables sequentially after the frameBuffer.
#Since frameBuffer occupies 0x80000 bytes (0x10010000 to 0x1008FFFF), the first .word variable (xVel) starts at 0x10090000, and subsequent variables follow:
#xVel: 0x10090000 (4 bytes).
#yVel: 0x10090004 (4 bytes).
#xPos: 0x10090008 (4 bytes). ETC

xVel:		.word	0		# x velocity start 0
yVel:		.word	0		# y velocity start 0
xPos:		.word	50		# x position
yPos:		.word	27		# y position
tail:		.word	7624		# location of rail on bit map display
appleX:		.word	32		# apple x position
appleY:		.word	16		# apple y position



snakeUp:	.word	0x0000ff00	# green pixel for when snaking moving up
snakeDown:	.word	0x0100ff00	# green pixel for when snaking moving down
snakeLeft:	.word	0x0200ff00	# green pixel for when snaking moving left
snakeRight:	.word	0x0300ff00	# green pixel for when snaking moving right
#THESE ARE USED TO ENCODE BOTH DIRECTION AND COLOR
#0x0000(up) ff00(color green)
#0x0100(down) ff00(color green)
#0x0300(right) ff00(color green)
#0x0200(left) ff00(color green)


xConversion:	.word	64		# x value for converting xPos to bitmap display
yConversion:	.word	4		# y value for converting (x, y) to bitmap display


.text
main:

### DRAW BACKGROUND SECTION
#Clarifying the Questions
#“The screen memory is at 0x10010000 from the start”:
#Yes, in the MARS simulator, the bitmap display’s memory is mapped to start at 0x10010000. This is where pixel data is written to update the screen.
#The frameBuffer is allocated at this address to serve as the memory buffer for the display.
#“The next space we reserve is for the pixels?”:
#The frameBuffer: .space 0x80000 reserves 524,288 bytes (0x80000) starting at 0x10010000 specifically for pixel data (512 * 256 pixels * 4 bytes per pixel).
#This is the first allocation in the .data section, and it directly corresponds to the screen’s pixel buffer.
#“What about the rest of .word we have in the .data”:
#The other .word directives (xVel, yVel, etc.) are additional variables stored in the .data section after the frameBuffer. They are not part of the pixel data but are used to store game state (e.g., snake position, velocity, colors).
#These variables are allocated in memory immediately following the frameBuffer’s 0x80000 bytes.

	la 	$t0, frameBuffer	# load frame buffer addres
	li 	$t1, 8192		# save 512*256 pixels
	li 	$t2, 0x00d3d3d3		# load light gray color
l1:
	sw   	$t2, 0($t0)
	addi 	$t0, $t0, 4 	# advance to next pixel position in display
	addi 	$t1, $t1, -1	# decrement number of pixels
	bnez 	$t1, l1		# repeat while number of pixels is not zero


#Step-by-Step Analysis of l1
#$t0: Points to the current pixel's address in frameBuffer.
#$t1: Tracks the remaining number of pixels to process (starts at 8192).
#$t2: Holds the light gray color value (0x00d3d3d3).

#Initialization (before the loop):
#$t0 is loaded with the starting address of frameBuffer (the memory region for the bitmap display).
#$t1 is set to 8192, which represents the total number of pixels in the 512x256 display (512 * 256 / 4 = 8192, accounting for 4 bytes per pixel).
#$t2 is loaded with the light gray color value (0x00d3d3d3).

#Loop Body (l1):
#sw $t2, 0($t0): Stores the light gray color (0x00d3d3d3) at the memory address in $t0, coloring the current pixel.
#addi $t0, $t0, 4: Increments $t0 by 4 to point to the next pixel's memory address (since each pixel is 4 bytes).
#addi $t1, $t1, -1: Decrements the pixel counter ($t1) by 1.
#bnez $t1, l1: Branches back to l1 if $t1 is not zero, continuing the loop until all 8192 pixels are processed.
	


### DRAW BORDER SECTION#################################################################################

#The game operates in a unit-based coordinate system, where each unit is an 8x8 pixel square. This means:

#Width in units: 512 pixels / 8 pixels per unit = 64 units wide.
#Height in units: 256 pixels / 8 pixels per unit = 32 units high.
#Thus, the game grid is 64 units wide and 32 units high, and each unit corresponds to an 8x8 pixel block on the display.


#The first 4 bytes (address frameBuffer + 0) store the color of the pixel at (x=0, y=0) (top-left corner).
#The next 4 bytes (address frameBuffer + 4) store the pixel at (x=1, y=0).
#After 512 pixels OR 64 UNITS (2048 bytes = 512 * 4), the first row (y=0) is complete, and the next 4 bytes (address frameBuffer + 2048) store the pixel at (x=0, y=1).
#This continues until the last pixel at (x=511, y=255), stored at address frameBuffer + 0x7FFFC (524,284 bytes).
	
	# top wall section
	la	$t0, frameBuffer	# load frame buffer addres
	addi	$t1, $zero, 64		# t1 = 64 length of row
	li 	$t2, 0x00000000		# load black color


drawBorderTop:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 4		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderTop	# repeat unitl pixel count == 0
	
	# Bottom wall section
	la	$t0, frameBuffer	# load frame buffer addres
	addi	$t0, $t0, 7936		# set pixel to be near the bottom left
	addi	$t1, $zero, 64		# t1 = 512 length of row

drawBorderBot:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 4		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderBot	# repeat unitl pixel count == 0
	
	# left wall section
	la	$t0, frameBuffer	# load frame buffer address
	addi	$t1, $zero, 256		# t1 = 512 length of col

drawBorderLeft:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 256		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderLeft	# repeat unitl pixel count == 0
	
	# Right wall section
	la	$t0, frameBuffer	# load frame buffer address
	addi	$t0, $t0, 508		# make starting pixel top right
	addi	$t1, $zero, 255		# t1 = 512 length of col

drawBorderRight:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 256		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderRight	# repeat unitl pixel count == 0

#Horizontal by 4
#


	la 	$t0, frameBuffer	# load frame buffer addres
	#8192-128-1536
	addi	$t0, $t0, 6528		# set pixel to be near the bottom left
	li 	$t2, 0x00ffcc00		# load YELLOW COLOR
	sw	$t2, 0($t0)		# color YELLOW
	addi	$t0, $t0, 4		# go to next pixe

	sw	$t2, 0($t0)		# color YELLOW
	addi	$t0, $t0, 4		# go to next pixe
	sw	$t2, 0($t0)		# color YELLOW
	addi	$t0, $t0, 4		# go to next pixe
	sw	$t2, 0($t0)		# color YELLOW
	addi	$t0, $t0, 4		# go to next pixe
	sw	$t2, 0($t0)		# color YELLOW
	addi	$t0, $t0, 4		# go to next pixe
	sw	$t2, 0($t0)		# color YELLOW
	addi	$t0, $t0, 4		# go to next pixe
	sw	$t2, 0($t0)		# color YELLOW
	addi	$t0, $t0, 4		# go to next pixe
	sw	$t2, 0($t0)		# color YELLOW
	addi	$t0, $t0, 4		# go to next pixe





	la 	$t0, frameBuffer	# load frame buffer addres
	#8192-128-1536
	addi	$t0, $t0, 6528		# 
	addi	$t0, $t0, 256

	sw	$t2, 0($t0)		# color YELLOW
	addi	$t0, $t0, 4		# go to next pixe
	sw	$t2, 0($t0)		# color YELLOW
	addi	$t0, $t0, 4		# go to next pixe
	sw	$t2, 0($t0)		# color YELLOW
	addi	$t0, $t0, 4		# go to next pixe
	sw	$t2, 0($t0)		# color YELLOW
	addi	$t0, $t0, 4		# go to next pixe
	sw	$t2, 0($t0)		# color YELLOW
	addi	$t0, $t0, 4		# go to next pixe
	sw	$t2, 0($t0)		# color YELLOW
	addi	$t0, $t0, 4		# go to next pixe
	sw	$t2, 0($t0)		# color YELLOW
	addi	$t0, $t0, 4		# go to next pixe




	la 	$t0, frameBuffer	# load frame buffer addres
	#8192-128-1536
	addi	$t0, $t0, 4096		# 
	sw	$t2, 0($t0)		# color YELLOW
	
	
la	$t0, frameBuffer	# t0 = 0x10010000
addiu	$t1, $zero, 2368	# offset = (8 * 64 + 16) * 4
addu	$t0, $t0, $t1		# t0 = 0x10010840
sw	$t2, 0($t0)		# draw green unit at (16, 8)


	
	

	





 ##############################################################################  


	### draw initial snake section
	la	$t0, frameBuffer	# load frame buffer address
	lw	$s2, tail		# s2 = tail of snake,Loads the value 7624 (the initial tail offset) into $s2. This offset represents the memory location of the snake’s tail relative to frameBuffer.
	lw	$s3, snakeUp		# s3 = direction of snake
	
	add	$t1, $s2, $t0		# t1 = tail start on bit map display
	sw	$s3, 0($t1)		# draw pixel where snake is
	addi	$t1, $t1, -256		# set t1 to pixel above. THIS IS HOW WE MOVE!!!
	sw	$s3, 0($t1)		# draw pixel where snake currently is

#This creates a two-segment snake: tail at (50, 29) and another segment at (50, 28), moving toward the head at (50, 27).
#Why -256?
#The value 256 corresponds to moving one unit up in the unit-based coordinate system:
#The offset formula is (y_unit * 64 + x_unit) * 4.
#Decreasing y_unit by 1: (y_unit - 1) * 64 + x_unit reduces the offset by 64 * 4 = 256 bytes.
#Since the snake is moving up, the second segment is one unit higher (y=28 vs. y=29), and the address decreases by 256 bytes.


	#addi	$t1, $t1, -256		# set t1 to pixel above
	#sw	$s3, 0($t1)		# draw pixel where snake currently is
	
	### draw initial apple
	jal 	drawApple













# This is the update function for game
# psudeocode
# input = get user input
# if input == w { moveUp();}
# if input == s { moveDown();}	
# if input == a { moveLeft();}	
# if input == d { moveRigth();}	

### each move method has similar code
# moveDirection () {
#	dir = direction of snake
#	updateSnake(dir)
#	updateSnakeHeadPosition()
#	go back to beginning of update fucntion
# } 	

# Registers:
# t3 = key press input
# s3 = direction of the snake

gameUpdateLoop:

	lw	$t3, 0xFFFF0000 #keyboard control register in MARS, Bit 0 is set to 1 when a key is pressed (indicating input is available).
	beqz	$t3, gameUpdateLoop#If $t3 is zero (no key pressed), branches back to gameUpdateLoop, effectively looping until input is detected.
	lw	$t3, 0xffff0004	#a key is pressed, loads the ASCII value of the key from the keyboard data register (0xFFFF0004) into $t3
	
	### Sleep for 66 ms so frame rate is about 15, "stops" the game so we can actually play and have time to press keys
	addi	$v0, $zero, 32	# syscall sleep
	addi	$a0, $zero, 66	# 66 ms
	syscall
	
	beq	$t3, 100, moveRight	# if key press = 'd' branch to moveright
	beq	$t3, 97, moveLeft	# else if key press = 'a' branch to moveLeft
	beq	$t3, 119, moveUp	# if key press = 'w' branch to moveUp
	beq	$t3, 115, moveDown	# else if key press = 's' branch to moveDown

	
moveUp:
	lw	$s3, snakeUp	# s3 = direction of snake, loads the value of snakeUp (0x0000ff00, green color(ff) with “up” flag(0000) into $s3.
	add	$a0, $s3, $zero	# a0 = direction of snake, copies the value in $s3 (0x0000ff00) to $a0, $a0 is the argument register used to pass the direction/color to the updateSnake function
	jal	updateSnake
	
	# move the snake
	jal 	updateSnakeHeadPosition
	
	j	exitMoving 	

moveDown:
	lw	$s3, snakeDown	# s3 = direction of snake
	add	$a0, $s3, $zero	# a0 = direction of snake
	jal	updateSnake
	
	# move the snake
	jal 	updateSnakeHeadPosition
	
	j	exitMoving
	
moveLeft:
	lw	$s3, snakeLeft	# s3 = direction of snake
	add	$a0, $s3, $zero	# a0 = direction of snake
	jal	updateSnake
	
	# move the snake
	jal 	updateSnakeHeadPosition
	
	j	exitMoving
	
moveRight:
	lw	$s3, snakeRight	# s3 = direction of snake
	add	$a0, $s3, $zero	# a0 = direction of snake
	jal	updateSnake
	
	# move the snake
	jal 	updateSnakeHeadPosition

	j	exitMoving

exitMoving:
	j 	gameUpdateLoop		# loop back to beginning




# this function update the snake on the bitmap display and changes its velocity
# Param 1 is the direction
# code logic steps
# updateSnake(colorDir) {
#	getBitMapLocation;
#	store color dir in bitMapLoction
#	getDirection of snake
# 	update velocity based on snake
#	check if head == apple
#		get random new apple coordinates
#		draw apple on bitmap display
#		exit updateSnake function
#	check head != background color
#		game over
#	Remove tail from bit map display
#	update new tail base upon tail direction
#	exit updateSnake function
# }	




updateSnake:

	addiu 	$sp, $sp, -24	# Allocates 24 bytes of stack space for the function’s stack frame

	#The 24 bytes are used to store:
	#The caller’s frame pointer ($fp, 4 bytes).
	#The return address ($ra, 4 bytes).


	sw 	$fp, 0($sp)	# Preserves the caller’s frame pointer so it can be restored when updateSnake returns.
	sw 	$ra, 4($sp)	# Preserves the return address so updateSnake can return to the caller (gameUpdateLoop).

	addiu 	$fp, $sp, 20	# setup updateSnake frame pointer- TBD
	
	### DRAW HEAD
	lw	$t0, xPos		# t0 = xPos of snake
	lw	$t1, yPos		# t1 = yPos of snake
	lw	$t2, xConversion	# t2 = 64
	mult	$t1, $t2		# yPos * 64
	mflo	$t3			# t3 = yPos * 64
	add	$t3, $t3, $t0		# t3 = yPos * 64 + xPos
	lw	$t2, yConversion	# t2 = 4
	mult	$t3, $t2		# (yPos * 64 + xPos) * 4
	mflo	$t0			# t0 = (yPos * 64 + xPos) * 4
	
	la 	$t1, frameBuffer	# load frame buffer address
	add	$t0, $t1, $t0		# t0 = (yPos * 64 + xPos) * 4 + frame address
	lw	$t4, 0($t0)		# save original val of pixel in t4
	sw	$a0, 0($t0)		# store direction plus color on the bitmap display
	
	
	### Set Velocity
	lw	$t2, snakeUp			# load word snake up = 0x0000ff00
	beq	$a0, $t2, setVelocityUp		# if head direction and color == snake up branch to setVelocityUp
	
	lw	$t2, snakeDown			# load word snake up = 0x0100ff00
	beq	$a0, $t2, setVelocityDown	# if head direction and color == snake down branch to setVelocityUp
	
	lw	$t2, snakeLeft			# load word snake up = 0x0200ff00
	beq	$a0, $t2, setVelocityLeft	# if head direction and color == snake left branch to setVelocityUp
	
	lw	$t2, snakeRight			# load word snake up = 0x0300ff00
	beq	$a0, $t2, setVelocityRight	# if head direction and color == snake right branch to setVelocityUp
	
setVelocityUp:
	addi	$t5, $zero, 0		# set x velocity to zero
	addi	$t6, $zero, -1	 	# set y velocity to -1
	sw	$t5, xVel		# update xVel in memory
	sw	$t6, yVel		# update yVel in memory
	j exitVelocitySet
	
setVelocityDown:
	addi	$t5, $zero, 0		# set x velocity to zero
	addi	$t6, $zero, 1 		# set y velocity to 1
	sw	$t5, xVel		# update xVel in memory
	sw	$t6, yVel		# update yVel in memory
	j exitVelocitySet
	
setVelocityLeft:
	addi	$t5, $zero, -1		# set x velocity to -1
	addi	$t6, $zero, 0 		# set y velocity to zero
	sw	$t5, xVel		# update xVel in memory
	sw	$t6, yVel		# update yVel in memory
	j exitVelocitySet
	
setVelocityRight:
	addi	$t5, $zero, 1		# set x velocity to 1
	addi	$t6, $zero, 0 		# set y velocity to zero
	sw	$t5, xVel		# update xVel in memory
	sw	$t6, yVel		# update yVel in memory
	j exitVelocitySet
	
exitVelocitySet:
	
	### Head location checks
	li 	$t2, 0x00ff0000		# load red color
	bne	$t2, $t4, headNotApple	# if head location is not the apple branch away
	
	jal 	newAppleLocation
	jal	drawApple
	
	jal 	newAppleLocation
	jal	drawApple


	jal 	newAppleLocation
	jal	drawApple


	j	exitUpdateSnake
	
headNotApple:

	li	$t2, 0x00d3d3d3			# load light gray color
	beq	$t2, $t4, validHeadSquare	# if head location is background branch away
	
	addi 	$v0, $zero, 10	# exit the program
	syscall
	
validHeadSquare:

	### Remove Tail
	lw	$t0, tail		# t0 = tail
	la 	$t1, frameBuffer	# load frame buffer address
	add	$t2, $t0, $t1		# t2 = tail location on the bitmap display
	li 	$t3, 0x00d3d3d3		# load light gray color
	lw	$t4, 0($t2)		# t4 = tail direction and color
	sw	$t3, 0($t2)		# replace tail with background color
	
	### update new Tail
	lw	$t5, snakeUp			# load word snake up = 0x0000ff00
	beq	$t5, $t4, setNextTailUp		# if tail direction and color == snake up branch to setNextTailUp
	
	lw	$t5, snakeDown			# load word snake up = 0x0100ff00
	beq	$t5, $t4, setNextTailDown	# if tail direction and color == snake down branch to setNextTailDown
	
	lw	$t5, snakeLeft			# load word snake up = 0x0200ff00
	beq	$t5, $t4, setNextTailLeft	# if tail direction and color == snake left branch to setNextTailLeft
	
	lw	$t5, snakeRight			# load word snake up = 0x0300ff00
	beq	$t5, $t4, setNextTailRight	# if tail direction and color == snake right branch to setNextTailRight
	
setNextTailUp:
	addi	$t0, $t0, -256		# tail = tail - 256
	sw	$t0, tail		# store  tail in memory
	j exitUpdateSnake
	
setNextTailDown:
	addi	$t0, $t0, 256		# tail = tail + 256
	sw	$t0, tail		# store  tail in memory
	j exitUpdateSnake
	
setNextTailLeft:
	addi	$t0, $t0, -4		# tail = tail - 4
	sw	$t0, tail		# store  tail in memory
	j exitUpdateSnake
	
setNextTailRight:
	addi	$t0, $t0, 4		# tail = tail + 4
	sw	$t0, tail		# store  tail in memory
	j exitUpdateSnake
	
exitUpdateSnake:
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code
	
updateSnakeHeadPosition:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updateSnake frame pointer	
	
	lw	$t3, xVel	# load xVel from memory
	lw	$t4, yVel	# load yVel from memory
	lw	$t5, xPos	# load xPos from memory
	lw	$t6, yPos	# load yPos from memory
	add	$t5, $t5, $t3	# update x pos
	add	$t6, $t6, $t4	# update y pos
	sw	$t5, xPos	# store updated xpos back to memory
	sw	$t6, yPos	# store updated ypos back to memory
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code

# this function draws the apple base upon x and y coordintes
# code logic
# drawApple() {
#	convert (x, y) to bitmap display
#	store red color into bitmap display
#	exit drawApple
# }
drawApple:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updateSnake frame pointer
	
	lw	$t0, appleX		# t0 = xPos of apple
	lw	$t1, appleY		# t1 = yPos of apple
	lw	$t2, xConversion	# t2 = 64
	mult	$t1, $t2		# appleY * 64
	mflo	$t3			# t3 = appleY * 64
	add	$t3, $t3, $t0		# t3 = appleY * 64 + appleX
	lw	$t2, yConversion	# t2 = 4
	mult	$t3, $t2		# (yPos * 64 + appleX) * 4
	mflo	$t0			# t0 = (appleY * 64 + appleX) * 4
	
	la 	$t1, frameBuffer	# load frame buffer address
	add	$t0, $t1, $t0		# t0 = (appleY * 64 + appleX) * 4 + frame address
	li	$t4, 0x00ff0000
	sw	$t4, 0($t0)		# store direction plus color on the bitmap display
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code	

# This function finds a new spot for an apple after its been eaten
# does so randomly using syscall 42 which is a random number generator
# code logic:
# newAppleLocation() {
#	get random X from 0 - 63
# 	get random Y from 0 - 31
#	convert (x, y) to bit map display value
# 	if (bit map display value != gray background)
#		redo the randomize
#	once good apple spot found store x, y in memory
#	exit newAppleLocation
# }
newAppleLocation:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updateSnake frame pointer

redoRandom:		
	addi	$v0, $zero, 42	# random int 
	addi	$a1, $zero, 63	# upper bound
	syscall
	add	$t1, $zero, $a0	# random appleX
	
	addi	$v0, $zero, 42	# random int 
	addi	$a1, $zero, 31	# upper bound
	syscall
	add	$t2, $zero, $a0	# random appleY
	
	lw	$t3, xConversion	# t3 = 64
	mult	$t2, $t3		# random appleY * 64
	mflo	$t4			# t4 = random appleY * 64
	add	$t4, $t4, $t1		# t4 = random appleY * 64 + random appleX
	lw	$t3, yConversion	# t3 = 4
	mult	$t3, $t4		# (random appleY * 64 + random appleX) * 4
	mflo	$t4			# t1 = (random appleY * 64 + random appleX) * 4
	
	la 	$t0, frameBuffer	# load frame buffer address
	add	$t0, $t4, $t0		# t0 = (appleY * 64 + appleX) * 4 + frame address
	lw	$t5, 0($t0)		# t5 = value of pixel at t0
	
	li	$t6, 0x00d3d3d3		# load light gray color
	beq	$t5, $t6, goodApple	# if loction is a good sqaure branch to goodApple
	j redoRandom

goodApple:
	sw	$t1, appleX
	sw	$t2, appleY	

	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code

