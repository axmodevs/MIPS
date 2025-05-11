
###	Unit Width in pixels: 8 			    
###	Unit Heigh in Pixels: 8				    
###	Display Width in Pixels: 512			    
###	Display Height in Pixels: 256  			    
###	Base address for display 0x10010000 (static data) 


.data

frameBuffer: 	.space 	0x80000		#512 wide x 256 high pixels, JUST THE SIZE OF THE MEMORY FOR THE SCREEN, NOT THE ADRESS WICH IS 0x1001000. ###	Base address for display 0x10010000 (static data)   ###

#AFTER THIS WE HAVE:

#Each .word directive allocates 4 bytes in the .data section.
##The assembler places these variables sequentially after the frameBuffer.
#Since frameBuffer occupies 0x80000 bytes (0x10010000 to 0x1008FFFF), the first .word variable (xVel) starts at 0x10090000, and subsequent variables follow:
#xVel: 0x10090000 (4 bytes).
#yVel: 0x10090004 (4 bytes).
#xPos: 0x10090008 (4 bytes). ETC


xPos:		.word	50		# x position
yPos:		.word	27		# y position
position:		.word	7624		# location of rail on bit map display
enemieX:		.word	32		# enemie x position
enemieY:		.word	16		# enemie y position



xConversion:	.word	64		# x value for converting xPos to bitmap display
yConversion:	.word	4		# y value for converting (x, y) to bitmap display


.text
main:

### DRAW BACKGROUND SECTION
#Clarifying the Questions
#â€œThe screen memory is at 0x10010000 from the startâ€?:
#Yes, in the MARS simulator, the bitmap displayâ€™s memory is mapped to start at 0x10010000. This is where pixel data is written to update the screen.
#The frameBuffer is allocated at this address to serve as the memory buffer for the display.
#â€œThe next space we reserve is for the pixels?â€?:
#The frameBuffer: .space 0x80000 reserves 524,288 bytes (0x80000) starting at 0x10010000 specifically for pixel data (512 * 256 pixels * 4 bytes per pixel).
#This is the first allocation in the .data section, and it directly corresponds to the screenâ€™s pixel buffer.
#â€œWhat about the rest of .word we have in the .dataâ€?:
#The other .word directives (xVel, yVel, etc.) are additional variables stored in the .data section after the frameBuffer. They are not part of the pixel data but are used to store game state (e.g., snake position, velocity, colors).
#These variables are allocated in memory immediately following the frameBufferâ€™s 0x80000 bytes.

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



	





	
	
### DRAW ENEIMIES


	jal 	drawenemie
	addi	$t9, $zero, 300		# t1 = 64 length of row
enemies:
	jal 	newLocation
	jal	drawenemie
	addi	$t9, $t9, -1		# decrease counter
	bnez	$t9, enemies	# repeat unitl pixel count == 0



	jal 	newLocation
	jal	drawPoint
	
	jal 	newLocation
	jal	drawPoint
	
	jal 	newLocation
	jal	drawPoint
	
	jal 	newLocation
	jal	drawPoint
	
	jal 	newLocation
	jal	drawPoint







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
#t1 position
#t2 YELLOW COLOR
#t4 GREY COLOR
#t5 BLACK COLOR
#t6 RED COLOR

	la	$t0, frameBuffer	# load frame buffer address
	la 	$s7, frameBuffer	# load frame buffer addres for SCORE in Points

	addi	$s6, $zero, 5	# 5 score points (blue pixel)
	
	
	lw	$s2, position
	add	$t1, $s2, $t0		# t1 = position start on bit map display
	
	
	li 	$t2, 0x00ffcc00		# load YELLOW COLOR
	li 	$t4, 0x00d3d3d3		# load GREY
	li 	$t5, 0x00000000		# load BLACK 
	li	$t6, 0x00ff0000		# load red
	li	$t9, 0x000066ff		# load blue
	
	
	sw	$t2, 0($t1)		# DRAW THE PLAYER FOR THE FIRST TIME (SPAWN)

gameUpdateLoop:

	beqz	$s6, winScreen

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

	sw	$t4, 0($t1)		#we color the pixel we were located to background color
	addi	$t1, $t1, -256		# set t1 to pixel above. THIS IS HOW WE MOVE!!!
	lw	$t7, 0($t1)		# load pixel color at new head address
        beq	$t7, $t6, collisionDetected	# if pixel is red, branch to collisionDetected
        beq	$t7, $t9, pointScored	# if pixel is blue, point scored

	sw	$t2, 0($t1)		# draw 1 pixel 
	
	j	exitMoving 	

moveDown:
	sw	$t4, 0($t1)
	addi	$t1, $t1, 256		# set t1 to pixel down. THIS IS HOW WE MOVE!!!
	lw	$t7, 0($t1)		# load pixel color at new head address
        beq	$t7, $t6, collisionDetected	# if pixel is red, branch to collisionDetected
        beq	$t7, $t9, pointScored	# if pixel is blue, point scored

	sw	$t2, 0($t1)		# draw 1 pixel 

	
	j	exitMoving
	
moveLeft:
	
	sw	$t4, 0($t1)
	addi	$t1, $t1, -4		# set t1 to pixel to the left. THIS IS HOW WE MOVE!!!
	lw	$t7, 0($t1)		# load pixel color at new head address
        beq	$t7, $t6, collisionDetected	# if pixel is red, branch to collisionDetected
        beq	$t7, $t9, pointScored	# if pixel is blue, point scored

	sw	$t2, 0($t1)		# draw 1 pixel 
	

	j	exitMoving
	
moveRight:
	
	sw	$t4, 0($t1)
	addi	$t1, $t1, 4		# set t1 to pixel to the right. THIS IS HOW WE MOVE!!!
	lw	$t7, 0($t1)		# load pixel color at new head address
        beq	$t7, $t6, collisionDetected	# if pixel is red, branch to collisionDetected
        beq	$t7, $t9, pointScored	# if pixel is blue, point scored

	sw	$t2, 0($t1)		# draw 1 pixel 

	j	exitMoving

exitMoving:
	j 	gameUpdateLoop		# loop back to beginning





collisionDetected:

	sw   	$t6, 0($t0)
	addi 	$t0, $t0, 4 	# advance to next pixel position in display
	sw   	$t5, 0($t0)
	addi 	$t0, $t0, 4	# advance to next pixel position in display
	sw   	$t2, 0($t0)
	addi 	$t0, $t0, 4	# advance to next pixel position in display
	
	
	addi 	$t1, $t1, -1	# decrement number of pixels
	bnez 	$t1, collisionDetected	# repeat while number of pixels is not zero
    	li	$v0, 10			# syscall code for exit
    	syscall


pointScored:
	addi	$s6, $s6, -1
	sw	$t2, 0($t1)		# draw 1 pixel (player corrsing over point=
	addi 	$s7, $s7, 8
	sw   	$t9, 0($s7) 	#draw score in top left screen 1 blue pixel per score point
	j 	gameUpdateLoop
	
winScreen:
	sw   	$t9, 0($t0)
	addi 	$t0, $t0, 4 	# advance to next pixel position in display	
	
	addi 	$t1, $t1, -1	# decrement number of pixels
	bnez 	$t1, winScreen	# repeat while number of pixels is not zero
    	li	$v0, 10			# syscall code for exit
    	syscall







# this function draws the enemie base upon x and y coordintes
# code logic
# drawenemie() {
#	convert (x, y) to bitmap display
#	store red color into bitmap display
#	exit drawenemie
# }
drawenemie:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updateSnake frame pointer
	
	lw	$t0, enemieX		# t0 = xPos of enemie
	lw	$t1, enemieY		# t1 = yPos of enemie
	lw	$t2, xConversion	# t2 = 64
	mult	$t1, $t2		# enemieY * 64
	mflo	$t3			# t3 = enemieY * 64
	add	$t3, $t3, $t0		# t3 = enemieY * 64 + enemieX
	lw	$t2, yConversion	# t2 = 4
	mult	$t3, $t2		# (yPos * 64 + enemieX) * 4
	mflo	$t0			# t0 = (enemieY * 64 + enemieX) * 4
	
	la 	$t1, frameBuffer	# load frame buffer address
	add	$t0, $t1, $t0		# t0 = (enemieY * 64 + enemieX) * 4 + frame address
	li	$t4, 0x00ff0000
	sw	$t4, 0($t0)		# store direction plus color on the bitmap display
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code
	
drawPoint:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updateSnake frame pointer
	
	lw	$t0, enemieX		# t0 = xPos of enemie
	lw	$t1, enemieY		# t1 = yPos of enemie
	lw	$t2, xConversion	# t2 = 64
	mult	$t1, $t2		# enemieY * 64
	mflo	$t3			# t3 = enemieY * 64
	add	$t3, $t3, $t0		# t3 = enemieY * 64 + enemieX
	lw	$t2, yConversion	# t2 = 4
	mult	$t3, $t2		# (yPos * 64 + enemieX) * 4
	mflo	$t0			# t0 = (enemieY * 64 + enemieX) * 4
	
	la 	$t1, frameBuffer	# load frame buffer address
	add	$t0, $t1, $t0		# t0 = (enemieY * 64 + enemieX) * 4 + frame address
	li	$t4, 0x000066ff
	sw	$t4, 0($t0)		# store direction plus color on the bitmap display
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code	

# This function finds a new spot for an enemie after its been eaten
# does so randomly using syscall 42 which is a random number generator
# code logic:
# newLocation() {
#	get random X from 0 - 63
# 	get random Y from 0 - 31
#	convert (x, y) to bit map display value
# 	if (bit map display value != gray background)
#		redo the randomize
#	once good enemie spot found store x, y in memory
#	exit newLocation
# }
newLocation:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updateSnake frame pointer

redoRandom:		
	addi	$v0, $zero, 42	# random int 
	addi	$a1, $zero, 63	# upper bound
	syscall
	add	$t1, $zero, $a0	# random enemieX
	
	addi	$v0, $zero, 42	# random int 
	addi	$a1, $zero, 31	# upper bound
	syscall
	add	$t2, $zero, $a0	# random enemieY
	
	lw	$t3, xConversion	# t3 = 64
	mult	$t2, $t3		# random enemieY * 64
	mflo	$t4			# t4 = random enemieY * 64
	add	$t4, $t4, $t1		# t4 = random enemieY * 64 + random enemieX
	lw	$t3, yConversion	# t3 = 4
	mult	$t3, $t4		# (random enemieY * 64 + random enemieX) * 4
	mflo	$t4			# t1 = (random enemieY * 64 + random enemieX) * 4
	
	la 	$t0, frameBuffer	# load frame buffer address
	add	$t0, $t4, $t0		# t0 = (enemieY * 64 + enemieX) * 4 + frame address
	lw	$t5, 0($t0)		# t5 = value of pixel at t0
	
	li	$t6, 0x00d3d3d3		# load light gray color
	beq	$t5, $t6, goodenemie	# if loction is a good sqaure branch to goodenemie
	j redoRandom

goodenemie:
	sw	$t1, enemieX
	sw	$t2, enemieY	

	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code
