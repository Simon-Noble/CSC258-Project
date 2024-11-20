.data
displayaddress:     .word       0x10008000
Board: .half 0:128      # array of 128 half words (8 bits) used for storing the board. X,Y position 0,0 
                        # is element 0. Y incemets every 8 words (8*8 = 64 bits). The top left part of the 
                        # board is 0,0
                        
                        # Piece Reference:  (RGB order and NSEW order with Y replacing G)
                        #   0 - Empty space
                        #   1 - Red Virus
                        #   2 - Yellow Virus
                        #   3 - Blue virus
                        
                        #   4 - Red Pill No connection
                        #   5 - Red Pill Connected Up
                        #   6 - Red Pill Connected Left
                        #   7 - Red Pill Connected Down
                        #   8 - Red Pill Connected Right
                        
                        #   9 - Yellow Pill No connection
                        #   10 - Yellow Pill Connected Up
                        #   11 - Yellow Pill Connected Left
                        #   12 - Yellow Pill Connected Down
                        #   13 - Yellow Pill Connected Right
                        
                        #   14 - Blue Pill No connection
                        #   15 - Blue Pill Connected Up
                        #   16 - Blue Pill Connected Left
                        #   17 - Blue Pill Connected Down
                        #   18 - Blue Pill Connected Right
                        
                        #   Higher Values should not be expected 
                        


State: .byte 0:1        # This byte tracks whether the next check should be for player controled movement (0),
                        # deleting pieces(1), gravity movement (2),  generate a new piece (3)
capsule_x:          .word       0
capsule_y:          .word       0
.text
main:
addi $t0 $zero 1 # Temporary testing
la $t1 Board
addi $t0, $zero, 5

sll $t2, $t0, 1     # Update the offset to be correct

add $t2, $t2, $t1 
addi $t3, $zero, 2
addi $t4, $t3, 2
sh $t4, 0($t1)
sh $t3 , 12($t2)
jal Generate_Piece


Start_Main_Loop:
la $a0, Gravity
jal Access_All
la $a0, Gravity
jal Access_All
#j Start_Main_Loop


# ========= Plans For The Main Loop =======


# Initialize
# Start of Loop / Delay?
# Get Player Input
# Update Piece Positions
# Check if the game is over and exit
jal Draw_Graphics # Draw the new board
# Play secion of Music?
# Restart Loop
# Start a new game?

Exit:
li $v0 , 10             # Exit
syscall



Movement_Determiner:    # Reads the state and determines what function should be called
                        # Either calling gravity, player control, clearing rows, or 
                        # generating a new piece.

Generate_Piece:
la $t3, Board           # Load positions to write the pieces to
addi $t3, $t3, 6        # Left Position
addi $t4, $t3, 2        # Right Position



li $v0 , 42
li $a0 , 0
li $a1 , 6
syscall

sh $a0, 8($t1)  


add $t0, $zero, $zero       # Go to the space where a pice is made. The order is the same as the
beq $a0, $t0, Zero          # grapic in the assignment 
addi $t0, $zero, 1
beq $a0, $t0, One
addi $t0, $zero, 2
beq $a0, $t0, Two
addi $t0, $zero, 3
beq $a0, $t0, Three
addi $t0, $zero, 4
beq $a0, $t0, Four
addi $t0, $zero, 5
beq $a0, $t0, Five
# Piece Reference:  (RGB order and NSEW order with Y replacing G)
                        #   0 - Empty space
                        #   1 - Red Virus
                        #   2 - Yellow Virus
                        #   3 - Blue virus
                        
                        #   4 - Red Pill No connection
                        #   5 - Red Pill Connected Up
                        #   6 - Red Pill Connected Left
                        #   7 - Red Pill Connected Down
                        #   8 - Red Pill Connected Right
                        
                        #   9 - Yellow Pill No connection
                        #   10 - Yellow Pill Connected Up
                        #   11 - Yellow Pill Connected Left
                        #   12 - Yellow Pill Connected Down
                        #   13 - Yellow Pill Connected Right
                        
                        #   14 - Blue Pill No connection
                        #   15 - Blue Pill Connected Up
                        #   16 - Blue Pill Connected Left
                        #   17 - Blue Pill Connected Down
                        #   18 - Blue Pill Connected Right
                        
                        #   Higher Values should not be expected 
Zero:
addi $t0, $zero, 8
addi $t1, $zero, 6
J Set_Piece
One:
addi $t0, $zero, 18
addi $t1, $zero, 16
J Set_Piece
Two:
addi $t0, $zero, 13
addi $t1, $zero, 11
J Set_Piece
Three:
addi $t0, $zero, 8
addi $t1, $zero, 16
J Set_Piece
Four:
addi $t0, $zero, 8
addi $t1, $zero, 11
J Set_Piece
Five:
addi $t0, $zero, 18
addi $t1, $zero, 11
J Set_Piece
Set_Piece:
sh, $t0, 0($t3)
sh, $t1, 0($t4)
Exit_Piece_Generation:
jr $ra  


Access_All:         # Calls the given function on each element on the board. The function should take
                    # at most a single argument that is the location of the element it is being
                    # called on. Argument should come in $a0
                    # Elements are called from bottom to top
addi $sp, $sp, -4                    # Store Return Address on the stack
sw $ra, 0($sp)

addi $t0, $zero, 15      # Initialize the loop varable
addi $t1, $zero, -1   # Set Stop 
Access_All_Loop:
ble $t0, $t1, End_Access_All       # Begin Loop
sll $t2, $t0, 4        # Adjust position for the function
la $t3, Board

add $a1, $t2, $t3       # Set Parameter for the function     

# Store Varables
addi $sp, $sp, -4 # Store all important registers

sw $t0, 0($sp)
addi $sp, $sp, -4
sw $t1, 0($sp)
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)

addi $sp, $sp, -4
sw $a0, 0($sp)


jal Access_Row      # Call function
                    
                    # Load Variables
lw $a0, 0($sp) 
addi $sp, $sp, 4
lw $t3, 0($sp) 
addi $sp, $sp, 4
lw $t2, 0($sp) 
addi $sp, $sp, 4
lw $t1, 0($sp) 
addi $sp, $sp, 4
lw $t0, 0($sp) 
addi $sp, $sp, 4

addi $t0, $t0, -1           # Increment loop variable
j Access_All_Loop               # Loop
                    

End_Access_All:
lw $ra, 0($sp)      # Read return address from the stack
addi $sp, $sp, 4
jr $ra              # Exit function


Access_Row:         # Calls the function given on each elemen in the given row
                    # $a1 should be the address of the row to call a function on,
                    # and $a0 should be the addres of the function to call. The function should take 
                    # a single argument from $a0, which is the position to call the function on
addi $sp, $sp, -4                    # Store Return Address on the stack
sw $ra, 0($sp)

addi $t8, $a1, 0    # Load the board position into t8
addi $t0 $zero 0    # Set loop variable
addi $t1 $zero 8                # Set Stop Vairable
Access_Row_Loop_Start:
bge $t0, $t1, Access_Row_Exit   # Begin loop and check loop condition
sll $t2, $t0, 1     # Update the offset to be correct
add $t2, $t2, $t8   # Set position to read

addi $a1, $t2, 0

addi $sp, $sp, -4 # Store all important registers
sw $t0, 0($sp)
addi $sp, $sp, -4
sw $t1, 0($sp)
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)
addi $sp, $sp, -4
sw $t8, 0($sp)
addi $sp, $sp, -4
sw $a0, 0($sp)
addi $sp, $sp, -4
sw $a1, 0($sp)


jalr $a0
#lh $t3, 0($t2)      # Read value from memory
#addi $t3, $t3, 1    # Increment value in memory
#sh $t3, 0($t2)      # Save to memory

lw $a1, 0($sp)      # Load all registers
addi $sp, $sp, 4 
lw $a0, 0($sp) 
addi $sp, $sp, 4
lw $t8, 0($sp) 
addi $sp, $sp, 4
lw $t3, 0($sp) 
addi $sp, $sp, 4
lw $t2, 0($sp) 
addi $sp, $sp, 4
lw $t1, 0($sp) 
addi $sp, $sp, 4
lw $t0, 0($sp) 
addi $sp, $sp, 4

addi $t0, $t0, 1    #Increment Loop Variable
j Access_Row_Loop_Start # Restart loop
Access_Row_Exit:
lw $ra, 0($sp)      # Read return address from the stack
addi $sp, $sp, 4
jr $ra # Exit function

Add:
# Add one to the value in the memory address in $a1

la $t0, Board
sub $t1, $a1, $t0   
addi $t2, $zero, 0xf0 # Does something different to the bottom row
bge $t1, $t2, Skip


lh $t3, 0($a1) 
addi $t3, $t3, 3
sh $t3, 0($a1) 
Skip:
jr $ra


Gravity:                # Single argument $a1. Determine if the piece at the position should move down
                       # and move it if it should be.
addi $sp, $sp, -4                    # Store Return Address on the stack
sw $ra, 0($sp)

la $t0, Board
sub $t1, $a1, $t0   
addi $t2, $zero, 0xf0   # Check if we are in the bottom row, if so, return
bge $t1, $t2, Gravity_Return




lh $t0, 0($a1)              # $t0 is the value at the position we care about
addi $t1, $zero, 3

ble $t0, $t1, Gravity_Return    # Check if the value at the position is <= 3, if so, return
addi $t8, $zero, 1
sll $t8, $t8, 4
add $t8, $t8, $a1           # $t8 is the position of the piece below
lh $t9, 0($t8)              # $t9 is The value of the position below
bgtz $t9, Gravity_Return    # Check if the value at the position below it is > 0, if so, return.
# Check if the value is 6, 8, 11, 13, 16, 18
addi $t2, $zero, 6
beq $t0, $t2, Gravity_Right
addi $t2, $zero, 11
beq $t0, $t2, Gravity_Right
addi $t2, $zero, 16
beq $t0, $t2, Gravity_Right
addi $t2, $zero, 8
beq $t0, $t2, Gravity_Left
addi $t2, $zero, 13
beq $t0, $t2, Gravity_Left
addi $t2, $zero, 18
beq $t0, $t2, Gravity_Left
j Shift_Down
# If the value is 6, 11, 16, check the position to the right and down. If it is >0, return
Gravity_Left:
addi $t5, $zero, 1
sll $t5, $t5, 4
addi $t5,$t5, 2
add $t3, $t5, $a1 # $t3 is the position we care about
lh $t4, 0($t3)      # $t4 is the value we care about
bgtz $t4, Gravity_Return
j Shift_Down
# If the value is 8, 13, 18, check the value at the position tot he left and down, if >0, return
Gravity_Right:
addi $t5, $zero, 1
sll $t5, $t5, 4
addi $t6, $zero, 2
sub $t5,$t5, $t6
add $t3, $t5, $a1   # $t3 is the position we care about
lh $t4, 0($t3)      # $t4 is the value we care about
bgtz $t4, Gravity_Return
j Shift_Down

Shift_Down:
sh $t0, 0($t8)      # Set the piece at the position below to the same as the current piece.
sh $zero, 0($a1)       # Set the piece at the current position to 0
# Return
Gravity_Return:
lw $ra, 0($sp)      # Read return address from the stack
addi $sp, $sp, 4
jr $ra              # Exit function




Draw_Graphics:
addi $sp, $sp, -4                    # Store Return Address on the stack
sw $ra, 0($sp)
# ...
########################################
### First, I'll draw the square grid ###
########################################

#$s1 - $s7 will store the colours
li $s1, 0x321e96 # indigo, RGB 50, 30, 150
li $s2, 0xc5d6b6 # white, RGB 197, 214, 182
li $s3, 0xde126a # magenta, RGB 222, 18, 106
li $s4, 0xe6a015 # yellow, RGB 230, 160, 21
li $s5, 0x14bab7 # cyan, 20, 186, 183
li $s6, 0xe3b19a # beige, RGB 227, 177, 154
li $s6, 0x9c502d # brown, RGB 156, 80, 45

# Set up the parameters for the rectangle drawing function
add $a0, $zero, $zero          # Set the X coordinate for the top left corner of the rectangle (in pixels)
add $a1, $zero, $zero         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
addi $a2, $zero, 2          # Set the width of the rectangle (in pixels)
addi $a3, $zero, 2          # Set the height of the rectangle (in pixels)
li $t9, 0
add $t8, $zero, $s1

repeat_row:
jal draw_grid_row

new_row:
add $a0, $zero, $zero
addi $t9, $t9, 4
add $a1, $t9, $zero 
j repeat_row
repeat_end:


draw_grid_row:
jal draw_rect

beq $a1, 66, start_shift
beq $a0, 60, new_row     # Break out of the loop when $a0 == 1024
addi $a0, $a0, 4
add $a1, $t9, $zero 
j draw_grid_row




#########################Shifted grid#################################

start_shift:
addi $a0, $zero, 2          # Set the X coordinate for the top left corner of the rectangle (in pixels)
addi $a1, $zero, 2         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
addi $a2, $zero, 2          # Set the width of the rectangle (in pixels)
addi $a3, $zero, 2          # Set the height of the rectangle (in pixels)
li $t9, 0

repeat_shift:
jal shift_grid_row

new_shift:
addi $a0, $zero, 2
addi $t9, $t9, 4
addi $a1, $t9, 2
j repeat_shift
shift_end:
j main_jar_start


shift_grid_row:
jal draw_rect

beq $a1, 68, shift_end
beq $a0, 62, new_shift     # Break out of the loop when 
addi $a0, $a0, 4
addi $a1, $t9, 2 
j shift_grid_row

#################################
### Second, I'll make the jar ###
#################################
main_jar_start:
addi $a0, $zero, 24          # Set the X coordinate for the top left corner of the rectangle (in pixels)
addi $a1, $zero, 18         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
addi $a2, $zero, 16          # Set the width of the rectangle (in pixels)
addi $a3, $zero, 38          # Set the height of the rectangle (in pixels)
add $t8, $zero, $zero

jal draw_rect

addi $a0, $zero, 30          # Set the X coordinate for the top left corner of the rectangle (in pixels)
addi $a1, $zero, 14         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
addi $a2, $zero, 4          # Set the width of the rectangle (in pixels)
addi $a3, $zero, 16         # Set the height of the rectangle (in pixels)
add $t8, $zero, $zero

jal draw_rect

addi $a0, $zero, 28          # Set the X coordinate for the top left corner of the rectangle (in pixels)
addi $a1, $zero, 10         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
addi $a2, $zero, 8          # Set the width of the rectangle (in pixels)
addi $a3, $zero, 4         # Set the height of the rectangle (in pixels)
add $t8, $zero, $zero

jal draw_rect
main_jar_end:
jal jar_wall_start

############################### Actual Jar ########################################

jar_wall_start:
addi $a0, $zero, 22          # Set the X coordinate for the top left corner of the rectangle (in pixels)
addi $a1, $zero, 16         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
addi $a2, $zero, 2          # Set the width of the rectangle (in pixels)
addi $a3, $zero, 2          # Set the height of the rectangle (in pixels)
add $t8, $zero, $s5
li $t7, 0

jal vertical_start
wall_end:
j end_background

vertical_start:
jal draw_rect
beq $a1, 58, vertical_start_end
addi $t7, $t7, 2
addi $a1, $t7, 16
j vertical_start
vertical_start_end:
addi $a0, $zero, 40
addi $a1, $zero, 16
li $t7, 0
j vertical_two

vertical_two:
jal draw_rect
beq $a1, 58, vertical_end
addi $t7, $t7, 2
addi $a1, $t7, 16
j vertical_two
vertical_end:
addi $a0, $zero, 24
addi $a1, $zero, 56
li $t7, 0

bottom_wall:
jal draw_rect
beq $a0, 40, bottom_end
addi $t7, $t7, 2
li $a1, 56
addi $a0, $t7, 24
j bottom_wall
bottom_end:
addi $a0, $zero, 26          # Set the X coordinate for the top left corner of the rectangle (in pixels)
addi $a1, $zero, 8         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
li $t7, 0

top_start:
jal draw_rect
beq $a0, 36, top_end
addi $t7, $t7, 2
li $a1, 8
addi $a0, $t7, 26
j top_start
top_end:
addi $a0, $zero, 24          # Set the X coordinate for the top left corner of the rectangle (in pixels)
addi $a1, $zero, 16         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
li $t7, 0

top_two:
jal draw_rect
beq $a0, 28, top_two_end
addi $t7, $t7, 2
li $a1, 16
addi $a0, $t7, 24
j top_two
top_two_end:
addi $a0, $zero, 34          # Set the X coordinate for the top left corner of the rectangle (in pixels)
addi $a1, $zero, 16         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
li $t7, 0

top_three:
jal draw_rect
beq $a0, 40, top_three_end
addi $t7, $t7, 2
li $a1, 16
addi $a0, $t7, 34
j top_three
top_three_end:
addi $a0, $zero, 26          # Set the X coordinate for the top left corner of the rectangle (in pixels)
addi $a1, $zero, 10         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
li $t7, 0

rmouth_start:
jal draw_rect
beq $a1, 14, rmouth_end
addi $t7, $t7, 2
addi $a1, $t7, 10
j rmouth_start
rmouth_end:
addi $a0, $zero, 28          # Set the X coordinate for the top left corner of the rectangle (in pixels)
addi $a1, $zero, 12         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
li $t7, 0

rrmouth_start:
jal draw_rect
beq $a1, 16, rrmouth_end
addi $t7, $t7, 2
addi $a1, $t7, 12
j rrmouth_start
rrmouth_end:
addi $a0, $zero, 36          # Set the X coordinate for the top left corner of the rectangle (in pixels)
addi $a1, $zero, 10         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
li $t7, 0

lmouth_start:
jal draw_rect
beq $a1, 14, lmouth_end
addi $t7, $t7, 2
addi $a1, $t7, 10
j lmouth_start
lmouth_end:
addi $a0, $zero, 34          # Set the X coordinate for the top left corner of the rectangle (in pixels)
addi $a1, $zero, 12         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
li $t7, 0

lrmouth_start:
jal draw_rect
beq $a1, 16, wall_end
addi $t7, $t7, 2
addi $a1, $t7, 12
j lrmouth_start
lrmouth_end:

#######################################
### Third, I'll addd the filpboards ###
#######################################

#######################################
### Fourth, I'll add the petri dish ###
#######################################

#########################################################
### Finally, I'll add the box for Mario and the title ###
#########################################################

#
#  The rectangle drawing function
#
#  $a0 = X coordinate for start of the line
#  $a1 = Y coordinate for start of the line
#  $a2 = wdith of the rectangle 
#  $a3 = height of the rectangle 
#  $t0 = the current row being drawn 
draw_rect:
add $t0, $zero, $zero       # create a loop variable with an iniital value of 0
row_start:
# Use the stack to store all registers that will be overwritten by draw_line
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
sw $t0, 0($sp)              # store $t0 on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
sw $a0, 0($sp)              # store $a0 on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
sw $a1, 0($sp)              # store $a1 on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
sw $a2, 0($sp)              # store $a2 on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
sw $ra, 0($sp)              # store $ra on the stack

jal draw_line               # call the draw_line function

# restore all the registers that were stored on the stack
lw $ra, 0($sp)              # restore $ra from the stack
addi $sp, $sp, 4            # move the stack pointer to the new top element
lw $a2, 0($sp)              # restore $a2 from the stack
addi $sp, $sp, 4            # move the stack pointer to the new top element
lw $a1, 0($sp)              # restore $a1 from the stack
addi $sp, $sp, 4            # move the stack pointer to the new top element
lw $a0, 0($sp)              # restore $a0 from the stack
addi $sp, $sp, 4            # move the stack pointer to the new top element
lw $t0, 0($sp)              # restore $t0 from the stack
addi $sp, $sp, 4            # move the stack pointer to the new top element

addi $a1, $a1, 1            # move to the next row to draw
addi $t0, $t0, 1            # increment the row variable by 1
beq $t0, $a3, row_end       # when the last line has been drawn, break out of the line-drawing loop
j row_start                 # jump to the start of the line-drawing section
row_end:
jr $ra                      # return to the calling program

#
#  The line drawing function
#
#  $a0 = X coordinate for start of the line
#  $a1 = Y coordinate for start of the line
#  $a2 = length of the line
#  
draw_line:
add $t1, $t8, $zero           # Set the colour of the line (to yellow)
lw $t0, displayaddress      # $t0 = base address for display
sll $a1, $a1, 8             # Calculate the Y offset to add to $t0 (multiply $a1 by 128)
sll $a0, $a0, 2             # Calculate the X offset to add to $t0 (multiply $a0 by 4)
add $t2, $t0, $a1           # Add the Y offset to $t0, store the result in $t2
add $t2, $t2, $a0           # Add the X offset to $t2 ($t2 now has the starting location of the line in bitmap memory)
# Calculate the final point in the line (start point + length x 4)
sll $a2, $a2, 2             # Multiply the length by 4
add $t3, $t2, $a2           # Calculate the address of the final point in the line, store result in $t3.
# Start the loop
line_start:
sw $t1, 0($t2)              # Draw a yellow pixel at the current location in the bitmap
# Loop until the current pixel has reached the final point in the line.
addi $t2, $t2, 4            # Move the current location to the next pixel
beq $t2, $t3, line_end      # Break out of the loop when $t2 == $t3
j line_start
# End the loop
line_end:
# Return to calling program
jr $ra

end_background:
lw $ra, 0($sp)      # Read return address from the stack
addi $sp, $sp, 4
jr $ra  
